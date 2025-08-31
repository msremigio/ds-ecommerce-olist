from os import curdir, path



print(path.relpath(__file__, start=curdir))
print(path.dirname(__file__))
print(path.abspath(__file__))
print(path.basename(__file__))