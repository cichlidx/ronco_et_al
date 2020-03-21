# m_matschiner Tue Mar 10 10:51:36 CET 2020

def get_generations_per_branch_length_unit(
        branch_length_units=None,
        generation_time=None):
    """
    Method to calculate the number of generations per branch length
    unit, given the branch length unit and a generation time.
    """
    if branch_length_units == "gen":
        generations_per_branch_length_unit = 1
    elif branch_length_units == "myr":
        generations_per_branch_length_unit = 10**6/generation_time
    else:
        generations_per_branch_length_unit = 1/generation_time
    return generations_per_branch_length_unit


def parse_species_tree(
        species_tree=None,
        branch_length_units="gen",
        Ne=None,
        generation_time=None):
    """
    Method to parse species trees in Newick
    (https://en.wikipedia.org/wiki/Newick_format) format.

    Trees are assumed to be rooted and ultrametric and branch lengths
    must be included and correspond to time, either in units of millions
    of years ("myr"), years ("yr"), or generations ("gen"; default).
    Leafs must be named. An example for an accepted tree string in
    Newick format is:
    (((human:5.6,chimpanzee:5.6):3.0,gorilla:8.6):9.4,orangutan:18.0)
    The tree string can end with a semi-colon, but this is not required.

    - An estimate of the effective population size Ne should be
        specified.
    - If and only if the branch lengths are not in units of
        generations, the generation time should be specified.
    """

    # Make sure a species tree is specified.
    if type(species_tree) is not str:
        raise ValueError("A species tree must be specified.")

    # Make sure that branch length units are either "myr", "yr", or "gen".
    allowed_branch_lenth_units = ["myr", "yr", "gen"]
    if branch_length_units not in allowed_branch_lenth_units:
        err = 'The specified units for branch lengths ('
        err += '"{}") are not accepted. '.format(branch_length_units)
        err += 'Accepted units are "myr" (millions of years), "yr" (years), '
        err += 'and "gen" (generations).'
        raise ValueError(err)

    # Make sure that the population size is either None or positive.
    if Ne is not None:
        try:
            Ne = float(Ne)
        except ValueError:
            raise ValueError("Population size Ne must be numeric.")
        if Ne <= 0:
            raise ValueError("Population size Ne must be > 0.")

    # Make sure that the generation time is either None or positive.
    if generation_time is not None:
        try:
            generation_time = float(generation_time)
        except ValueError:
            raise ValueError("Generation time must be numeric.")
        if generation_time <= 0:
            raise ValueError("Generation time must be > 0.")

    # Make sure that the generation time is specified if and only if
    # branch lengths are not in units of generations.
    if branch_length_units == "gen":
        if generation_time is not None:
            err = 'With branch lengths in units of generations ("gen"), '
            err += 'a generation time should not be specified additionally.'
            raise ValueError(err)
    else:
        if generation_time is None:
            err = 'With branch lengths in units of '
            err += '"{}", a generation time must be '.format(branch_length_units)
            err += 'specified additionally.'
            raise ValueError(err)

    # Make sure that a population size is specified.
    if Ne is None:
        raise ValueError("Ne should be specified.")

    # Get the number of generations per branch length unit.
    generations_per_branch_length_unit = get_generations_per_branch_length_unit(
        branch_length_units, generation_time
        )

    # Read the input file.
    species_tree_lines = species_tree.splitlines(False)
    if len(species_tree_lines) > 1:
        raise ValueError("The species tree has multiple lines.")
    tree_patterns = re.search('\\(.+\\)', species_tree_lines[0])
    if tree_patterns is None:
        raise ValueError("No species tree string found.")
    species_tree_string = tree_patterns.group(0)

    # Parse the newick tree string.
    root = newick.loads(species_tree_string)[0]

    # Set node depths (distances from root).
    max_depth = 0
    for node in root.walk():
        depth = 0
        moving_node = node
        while moving_node.ancestor:
            depth += moving_node.length
            moving_node = moving_node.ancestor
        node.depth = depth
        if depth > max_depth:
            max_depth = depth

    # Set node heights (distances from present).
    for node in root.walk():
        node.height = max_depth - node.depth

    # Get a list of species IDs.
    species_ids = sorted(root.get_leaf_names())

    # Determine at which time which populations should merge.
    sources = []
    destinations = []
    divergence_times = []
    for node in root.walk():
        if node.is_leaf is False:
            name_indices = []
            for descendants in node.descendants:
                leaf_names = (descendants.get_leaf_names())
                name_indices.append(species_ids.index(sorted(leaf_names)[0]))
            new_destination = sorted(name_indices)[0]
            name_indices.remove(sorted(name_indices)[0])
            for new_source in name_indices:
                sources.append(new_source)
                destinations.append(new_destination)
                divergence_times.append(node.height)

    # Sort the lists source_sets, destinations, and divergence_times
    # according to divergence_time.
    s = sorted(zip(divergence_times, sources, destinations))
    divergence_times, sources, destinations = map(list, zip(*s))

    # Define the species/population tree for msprime.
    population_configurations = []
    for _ in range(len(root.get_leaves())):
        population_configurations.append(
            msprime.PopulationConfiguration(
                initial_size=Ne))
    demographic_events = []
    for x in range(len(divergence_times)):
        demographic_events.append(
            msprime.MassMigration(
                time=divergence_times[x]*generations_per_branch_length_unit,
                source=sources[x],
                destination=destinations[x]))
        for y in range(len(root.get_leaves())):
            if y != sources[x]:
                demographic_events.append(
                    msprime.MigrationRateChange(
                        time=divergence_times[x]*generations_per_branch_length_unit,
                        rate=0,
                        matrix_index=(sources[x], y)))
                demographic_events.append(
                    msprime.MigrationRateChange(
                        time=divergence_times[x]*generations_per_branch_length_unit,
                        rate=0,
                        matrix_index=(y, sources[x])))

    # Return a tuple of population_configurations and demographic_events.
    return population_configurations, demographic_events

# Import libraries.
import msprime
import sys
import newick
import random
from random import randint
import datetime
import re
import os

# Get the command line arguments.
tree_file_name = sys.argv[1]
species_table_file_name = sys.argv[2]
within_tribe_migration_string = sys.argv[3]
vcf_outfile_name = sys.argv[4]

# Set simulation parameters.
pop_size = 20000
generation_time = 3
#within_tribe_migration = 1e-5
between_tribe_migration = 0
mut_rate = 3.5e-9
chr_length = 100000
rec_rate = 2.2e-8

# Read the species table.
table_species_ids = []
table_tribe_ids = []
species_table_file = open(species_table_file_name,"r")
species_table_lines = species_table_file.readlines()
for line in species_table_lines:
    line_list = line.split()
    table_species_ids.append(line_list[0])
    table_tribe_ids.append(line_list[1])

# Read the species tree string.
with open(tree_file_name, "r") as f:
    species_tree_string = f.read()

# Parse the species tree.
root = newick.loads(species_tree_string)[0]
species_ids = sorted(root.get_leaf_names())

# Parse the species tree with msprime and generate population configurations and demographic evens.
parsed_tuple = parse_species_tree(
    species_tree=species_tree_string,
    branch_length_units="myr",
    Ne=pop_size,
    generation_time=generation_time
    )
population_configurations = parsed_tuple[0]
demographic_events = parsed_tuple[1]
for n in population_configurations:
    n.sample_size = 2

# Check if the specified migration rate string is a number or a file name.
print('Preparing the migration matrix...', end='', flush=True)
if os.path.isfile(within_tribe_migration_string):
    within_tribe_migrations = []
    # Read the migration rate matrix.
    with open(within_tribe_migration_string) as f:
        dsuite_file_lines = f.readlines()
        dsuite_file_species_ids = dsuite_file_lines[0].split()
        migration_matrix = []
        for species1 in species_ids:
            row = []
            species1_index = table_species_ids.index(species1)
            if species1 in dsuite_file_species_ids:
                dsuite_species1_index = dsuite_file_species_ids.index(species1)
            else:
                dsuite_species1_index = None
            tribe1 = table_tribe_ids[species1_index]
            for species2 in species_ids:
                species2_index = table_species_ids.index(species2)
                if species2 in dsuite_file_species_ids:
                    dsuite_species2_index = dsuite_file_species_ids.index(species2)
                else:
                    dsuite_species2_index = None
                tribe2 = table_tribe_ids[species2_index]
                if species1 == species2:
                    row.append(0)
                elif tribe1 == tribe2:
                    if dsuite_species1_index is None or dsuite_species2_index is None:
                        row.append(0)
                    else:
                        row_list = dsuite_file_lines[dsuite_species1_index+1].split()
                        within_tribe_migration = float(row_list[dsuite_species2_index+1]) * 1E-5
                        row.append(within_tribe_migration)
                        within_tribe_migrations.append(within_tribe_migration)
                else:
                    row.append(between_tribe_migration)
            migration_matrix.append(row)
    print(" done. Mean within-tribe migration rate is " + str(sum(within_tribe_migrations)/len(within_tribe_migrations)) + ".")
else:
    # For each pair of species, set the pairwise migration rate, unless a migration matrix has already been provided.
    within_tribe_migration = float(within_tribe_migration_string)
    migration_matrix = []
    for species1 in species_ids:
        row = []
        species1_index = table_species_ids.index(species1)
        tribe1 = table_tribe_ids[species1_index]
        for species2 in species_ids:
            species2_index = table_species_ids.index(species2)
            tribe2 = table_tribe_ids[species2_index]
            if species1 == species2:
                row.append(0)
            elif tribe1 == tribe2:
                row.append(within_tribe_migration)
            else:
                row.append(between_tribe_migration)
        migration_matrix.append(row)
    print(" done.")

# Write the vcf file.
print('Simulating with msprime...', end='', flush=True)
new_tree_sequence_obj = msprime.simulate(
        population_configurations=population_configurations,
        migration_matrix=migration_matrix,
        demographic_events=demographic_events,
        mutation_rate=mut_rate,
        length=chr_length,
        recombination_rate=rec_rate,
        random_seed=random.randint(1, 10000000)
        )
print(" done.")

# Prepare the vcf header.
print('Preparing the vcf...', end='', flush=True)
vcf_string = '##fileformat=VCFv4.2\n'
now = datetime.datetime.now()
vcf_string += '##fileDate={}\n'.format(now.strftime("%Y%m%d"))
vcf_string += '##source=c-genie\n'
vcf_string += '##contig=<ID=1,length={}>\n'.format(chr_length)
vcf_string += '##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">\n'
vcf_string += '#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT'
for sp in range(0,len(species_ids)):
    vcf_string += '\t{}'.format(species_ids[sp])
vcf_string += '\n'

# Prepare vcf file.
DNA_alphabet = ['A','C','G','T']
n_variants = 0
in_gene_position = 0
for variant in new_tree_sequence_obj.variants():
    vp = int(variant.site.position)
    if vp > in_gene_position:  # exclude multiple mutations at the same site (i.e. at the moment we generate only biallelic sites) TO DO: make multiallelics in these cases
        in_gene_position = vp
        n_variants = n_variants + 1
        ra = randint(0, 3)
        ancestralBase = DNA_alphabet[ra]
        derivedPossibilities = DNA_alphabet[:ra] +  DNA_alphabet[ra+1:]
        rd = randint(0, 2)
        derivedBase = derivedPossibilities[rd]
        vcf_string += '1\t{}\t.\t{}\t{}\t.\t.\t.\tGT'.format(vp,ancestralBase,derivedBase)
        for sp in range(0,len(species_ids)):
            vcf_string += '\t{}|{}'.format(variant.genotypes[2*sp],variant.genotypes[(2*sp)+1])
        vcf_string += '\n'

# Write the vcf output file.
vcf_outfile = open(vcf_outfile_name, 'w')
vcf_outfile.write(vcf_string)
print(" done.")
