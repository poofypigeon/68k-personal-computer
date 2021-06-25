from random import randint
from plru_stim_gen import plru_tree

def gen_queries(min, max):
    addresses = []
    for _ in range(24):
        addresses.append(randint(min, max))

    queries = []
    for _ in range(128):
        queries.append(addresses[randint(0, len(addresses) - 1)])

    return queries

if __name__ == "__main__":
    height = 4

    block_list = []
    for i in range(2 ** height):
        block_list.append(0)
        
    tree = plru_tree(height = height)
    queries = gen_queries(0, 256)
    valid_iterator = iter(block_list)

    for query in queries:
        
        try:
            block_id = block_list.index(query)
            hit = 1
        except ValueError:
            hit = 0
            update_block = next(valid_iterator, -1)
            if update_block == -1:
                block_id = tree.bit_to_replace()
            else:
                block_id = block_list.index(update_block)
            
        block_list[block_id] = query
        tree.toggle(block_id)

        print("query: %3d; hit: %1d; block id: %2d" % (query, hit, block_id))