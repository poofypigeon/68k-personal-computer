class cache_block:
    def __init__(self):
        self.valid = False
        self.tag = 0

    def query(self, tag_query):
        return (self.tag == tag_query) and self.valid

