# This function is cited from stackoverflow
def complement(s):
    basecomplement = {'A': 'T', 'C': 'G', 'G': 'C', 'T': 'A'}
    letters = list(s)
    letters = [basecomplement[base] for base in letters]
    return ''.join(letters)

def reverse_complement(seq):
    return complement(seq[::-1])
