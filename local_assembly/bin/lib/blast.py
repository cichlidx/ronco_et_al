"""All blast commands used by aTRAM."""

import os
from os.path import basename, join
import re
import glob
import json
import lib.log as log


# Try to get the sequence name and which end it is from the fasta header
PARSE_HEADER = re.compile(r'^ \s* ( [^\s/_]+ ) [\s/_]? ( [12] )?', re.VERBOSE)

# Parse blast hits file
PARSE_RESULTS = re.compile(r'^ ( [^\s/_]+ ) [\s/_] ( [12] )', re.VERBOSE)


def create_db(temp_dir, fasta_file, shard):
    """Create a blast database."""
    cmd = 'makeblastdb -dbtype nucl -in {} -out {}'
    cmd = cmd.format(fasta_file, shard)
    log.subcommand(cmd, temp_dir)


def against_sra(args, state, hits_file, shard):
    """Blast the query sequences against an SRA blast database."""
    cmd = []

    if args['protein'] and state['iteration'] == 1:
        cmd.append('tblastn')
        cmd.append('-db_gencode {}'.format(args['db_gencode']))
    else:
        cmd.append('blastn')
        cmd.append('-evalue {}'.format(args['evalue']))

    cmd.append('-outfmt 15')
    cmd.append('-max_target_seqs {}'.format(args['max_target_seqs']))
    cmd.append('-out {}'.format(hits_file))
    cmd.append('-db {}'.format(shard))
    cmd.append('-query {}'.format(state['query_file']))

    command = ' '.join(cmd)
    log.subcommand(command, args['temp_dir'])


def against_contigs(blast_db, query_file, hits_file, **kwargs):
    """
    Blast the query sequence against the contigs.

    The blast output will have the scores for later processing.
    """
    cmd = []

    if kwargs['protein']:
        cmd.append('tblastn')
        cmd.append('-db_gencode {}'.format(kwargs['db_gencode']))
    else:
        cmd.append('blastn')

    cmd.append('-db {}'.format(blast_db))
    cmd.append('-query {}'.format(query_file))
    cmd.append('-out {}'.format(hits_file))
    cmd.append('-outfmt 15')

    command = ' '.join(cmd)
    log.subcommand(command, kwargs['temp_dir'])


def all_shard_paths(blast_db):
    """Get all of the BLAST shard names built by the preprocessor."""
    pattern = '{}.*.blast.nhr'.format(blast_db)

    files = glob.glob(pattern)
    if not files:
        err = ('No blast shards found. Looking for "{}"\n'
               'Verify the --work-dir and --file-prefix options.').format(
                   pattern[:-4])
        log.fatal(err)

    return sorted([f[:-4] for f in files])


def output_file_name(temp_dir, shrd_path):
    """Create a file name for blast results."""
    shard_name = basename(shrd_path)
    file_name = '{}.results.json'.format(shard_name)
    return join(temp_dir, file_name)


def temp_db_name(temp_dir, blast_db):
    """Generate a name for the temp DB used to filter the contigs."""
    file_name = basename(blast_db)
    return join(temp_dir, file_name)


def hits(json_file):
    """Extract the blast hits from the blast json output file."""
    hits_list = []

    with open(json_file) as blast_file:
        raw = blast_file.read()

        # Allow empty results
        if not raw:
            return []

        # Do not allow bad json
        try:
            obj = json.loads(raw)
        except json.decoder.JSONDecodeError:
            err = ('Blast output is not in JSON format. '
                   'You may need to upgrade blast.')
            log.fatal(err)

    raw_hits = obj['BlastOutput2'][0]['report']['results']['search'].get(
        'hits', [])

    for raw in raw_hits:
        for i, desc in enumerate(raw['description']):
            hit = dict(desc)
            hit['len'] = raw['len']
            hit.update(raw['hsps'][i])
            hits_list.append(hit)

    return hits_list


def command_line_args(parser):
    """Add optional blast arguments to the command-line parser."""
    group = parser.add_argument_group('optional blast arguments')

    group.add_argument('--db-gencode', type=int, default=1,
                       metavar='CODE',
                       help='The genetic code to use during blast runs. '
                            'The default is "1".')

    group.add_argument('--evalue', type=float, default=1e-10,
                       help='The default evalue is "1e-10".')

    group.add_argument('--max-target-seqs', type=int, default=100000000,
                       metavar='MAX',
                       help='Maximum hit sequences per shard. '
                            'Default is calculated based on the available '
                            'memory and the number of shards.')


def default_max_target_seqs(max_target_seqs, blast_db, max_memory):
    """Calculate the default max_target_seqs per shard."""
    if not max_target_seqs:
        all_shards = all_shard_paths(blast_db)
        max_target_seqs = int(2 * max_memory / len(all_shards)) * 1e6
    return max_target_seqs


def default_shard_count(shard_count, sra_files):
    """Calculate the default number of shards."""
    if not shard_count:
        total_fasta_size = 0
        for file_name in sra_files:
            file_size = os.path.getsize(file_name)
            if file_name.lower().endswith('q'):
                file_size /= 2  # Guessing that fastq files ~2x fasta files
            total_fasta_size += file_size
        shard_count = int(total_fasta_size / 2.5e8)
        shard_count = shard_count if shard_count else 1

    return shard_count


def make_blast_output_dir(blast_db):
    """Make blast DB output directory."""
    output_dir = os.path.dirname(blast_db)
    if output_dir and output_dir not in ['.', '..']:
        os.makedirs(output_dir, exist_ok=True)


def touchup_blast_db_names(blast_dbs):
    """Allow users to enter blast DB names with various suffixes."""
    pattern = (r'^ (.*?)'
               r'(  \.atram(_preprocessor)?\.log'
               r' | \.blast_\d{3}\.(nhr|nin|nsq)'
               r' | \.sqlite\.db  )?$')

    db_names = []

    for blast_db in blast_dbs:
        db_names.append(re.sub(pattern, r'\1', blast_db, re.I | re.X))

    return db_names
