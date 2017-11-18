require_relative 'manifest'
require 'tsort'

class RevisionDAG
    include TSort

    def initialize(nodehash)
        #assume node hash is {vertex: [children]}, all values are revision numbers (ints)
        @nodes = nodehash

    end

    def tsort_each_node(&block)
        @nodes.keys.each(&block)
    end

    def tsort_each_child(node, &block)
        @nodes[node].each(&block)
    end

    def each
        self.tsort.map do |r|
            
        end
    end
end
