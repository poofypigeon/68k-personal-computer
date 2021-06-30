from random import randint
from plru_stim_gen import plru_tree

global tag_bit_width
tag_bit_width = 8
global block_id_bit_width
block_id_bit_width = 4

def gen_queries(min, max):
    addresses = []
    for _ in range(24):
        addresses.append(randint(min, max - 1))

    queries = []
    for _ in range(128):
        queries.append(addresses[randint(0, len(addresses) - 1)])

    return queries

if __name__ == "__main__":
    block_list = []
    for i in range(2 ** block_id_bit_width):
        block_list.append(0)
        
    tree = plru_tree(height = block_id_bit_width)
    queries = gen_queries(0, 2 ** tag_bit_width)
    valid_iterator = iter(block_list)

    with open("../stimulus/set.stim", 'w') as file:
        for query in queries:
            if randint(0, 7) != 0:
                set_is_selected = 1
                try:
                    block_id = block_list.index(query)
                    query_hit = 1
                except ValueError:
                    query_hit = 0
                    update_block = next(valid_iterator, -1)
                    if update_block == -1:
                        block_id = tree.bit_to_replace()
                    else:
                        block_id = block_list.index(update_block)
                finally:
                    block_list[block_id] = query
                    tree.toggle(block_id)
            else:
                set_is_selected = 0
                try:
                    block_id = block_list.index(query)
                except ValueError:
                    block_id = 0
                finally:
                    query_hit = 0

            print("set_is_selected: %d ; tag_query: %-3d ; query_hit: %d ; hit_block_id: %-2d" % (set_is_selected, query, query_hit, block_id))
            file.write("%d %-3d %d %-2d\n" % (set_is_selected, query, query_hit, block_id))