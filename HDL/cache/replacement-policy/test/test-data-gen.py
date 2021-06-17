class plru_node:
    def __init__ (self, parent, state = 0):
        self.parent = parent
        self.left = None
        self.right = None
        self.state = state

class plru_tree:
    def __init__ (self, height):
        self.height = height
        self.root = plru_node(parent = None)
        self.leaves = []

        layer = [self.root]
        for i in range(height):
            



    # def toggle(bit):
    #     return
    # def current_replace_bit():
    #     return