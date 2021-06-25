from random import randint

class plru_node:
    def __init__ (self, parent = None, state = False):
        self.parent = parent
        self.left = None
        self.right = None
        self.state = state

    def toggle(self):
        self.state = not self.state

class plru_tree:
    def __init__ (self, height):
        self.height = height
        self.root = plru_node()
        self.leaves = []

        current_layer = [self.root]
        next_layer = []

        for _ in range(height):
            for node in current_layer:
                node.left = plru_node(parent = node)
                next_layer.append(node.left)
                node.right = plru_node(parent = node)
                next_layer.append(node.right)

            current_layer = next_layer
            next_layer = []

        self.leaves = current_layer

    def toggle(self, bit):
        current_node = self.leaves[bit]
        while current_node is not self.root:
            current_node = current_node.parent
            current_node.toggle()

    def bit_to_replace(self):
        current_node = self.root

        while (current_node not in self.leaves):
            if current_node.state == False:
                current_node = current_node.left
            else:
                current_node = current_node.right
        
        return self.leaves.index(current_node)

if __name__ == "__main__":
    tree = plru_tree(height = 4)

    file = open("plru.stim", 'wb')
    file_data = []

    for _ in range(2048):
        toggle_bit = randint(0, 15)
        file_data.extend(toggle_bit.to_bytes(4, 'little'))
        tree.toggle(toggle_bit)
        replace_bit = tree.bit_to_replace()
        print(f"{toggle_bit} {replace_bit}")
        file_data.extend(replace_bit.to_bytes(4, 'little'))

    file_bytes = bytes(file_data)
    file.write(file_bytes)

    file.close()
            

    