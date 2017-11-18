require 'yaml'

module RepoMerge
    DAG_LOC = ".repository/revisions.yaml"

    #def foo
    #    5
    #end

   # def bar
   #     @wat = 4
   # end

   #store/recover dag
    #

    
end

module Repo
    extend RepoMerge

    def Repo.wat
        foo
    end

end

p Repo.wat
