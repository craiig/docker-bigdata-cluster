#!/usr/bin/env python
import sys, re
import argparse
from pprint import pprint
from scipy.sparse import dok_matrix
import numpy as np

# parse args to read file
parser = argparse.ArgumentParser(description='return a compressed stack trace')
parser.add_argument('stack_trace_file')
args = parser.parse_args()

#track which function resolves to an id
_func2id = {} 
_id2func = {}
def func2id(id):
    if not id in _func2id:
        _func2id[id] = len(_func2id)
    return _func2id[id]

def build_id2func():
    for (k,v) in _func2id.iteritems():
        _id2func[v] = k

#holds (x,y) which is number of times that x directly called y
matrix = {}
def matrix_inc(t):
    matrix_add(t, 1)

def matrix_add(t, num):
    if not t in matrix:
        matrix[t] = 0
    matrix[t] = matrix[t] + num

with open(args.stack_trace_file, "r") as f:
    for l in f:
        #trim whitespace, split against ';'
        # since ; is at the end and this causes an empty element
        # trim the last element too
        stack = l.strip().split(';')[0:-1]

        #folds pairs of caller and calee together
        for (f,t) in zip(stack[0:-1], stack[1:]):
            fid = func2id(f)
            tid = func2id(t)

            #increment dict
            matrix_inc( (fid, tid) )

print >>sys.stderr, "done reading stack"
#build id to func
build_id2func()

#given a function X
# callers of function X are located at (_, X)
# callees of function X are located at (X, _)

#convert to dok matrix
print >>sys.stderr, "building matrix"
dok = dok_matrix( (len(_func2id), len(_func2id)) )
for (k,v) in matrix.iteritems():
    (f,t) = k
    # fname = _id2func[k[0]]
    # tname = _id2func[k[1]]
    # print (k,v)
    # print matrix[k]
    # print "%s -> %s: %s" % (fname, tname, v)
    # print (f,t)
    # print "**"
    dok[f,t] = v

#collapse the stack by looking for all ids that only have one coller
# and merging that into the caller function instead
# i don't think we need to do any numerical changes to the calls
# we can merge by adding the callers of the function to be deleted
# to the callees of it's parent

# todo improvement:
#if we do this from the leaf frames up, we only have to do this process
# once, but how to find the leaf frames?
# instead we can just try an iterative thing for now

# find leaf frames where (X,_) is empty

print >>sys.stderr, "collapsing stack"
shp = dok.get_shape()

# merge_map = { k:k for k,v in _func2id.iteritems() }
merge_map = {}
#check (_,X) column for single callees
# and mark them to be merged into their parents
for y in range(0,shp[1]): # y = calls to this function
    col = dok.getcol(y) #calls to this func
    nz = np.count_nonzero(col.toarray())
    if nz == 1:
        x = col.nonzero()[0][0]
        caller = _id2func[x]
        callee = _id2func[y]

        # we just need to write a map to merge child to parent
        merge_map[ callee ] = caller

        #this updates the matrix, but we don't really need this
        # print "merge %s into %s" % ( callee, caller )
        #get calls from this function and merge it into the caller
        # calls = dok.getrow(y)
        # for (k,v) in calls.iteritems():
            # oldpos = (y, k[1])
            # newpos = (x, k[1])
            # print "%s -> %s" % ( oldpos, newpos )
            # print "matrix[oldpos] = %s" % ( dok[oldpos] )
            # print "matrix[newpos] = %s" % ( dok[newpos] )
            # dok[newpos] += dok[oldpos]
            # dok[oldpos] = 0


#lastly print out the simplified stack, skipping the merged stacks
with open(args.stack_trace_file, "r") as f:
    for l in f:
        #trim whitespace, split against ';'
        # since ; is at the end and this causes an empty element
        # trim the last element too
        stack = l.strip().split(';')[0:-1]

        #folds pairs of caller and calee together
        old_stack = stack[:]
        stack = filter(lambda x: not x in merge_map, stack)
        print "%s;" % (";".join(stack))
