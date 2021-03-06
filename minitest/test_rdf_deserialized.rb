
require 'rubygems'
require 'json/ld'
require 'sparql'
require 'rdf/nquads'
require 'minitest/autorun'

describe 'example-codemeta-full.json deserialized to RDF' do
  before do
    @input = JSON.parse(File.read('example-codemeta-full.json'))
    @graph = RDF::Graph.new << JSON::LD::API.toRdf(@input)
  end

  it 'parses to a non-empty graph' do
    refute @graph.empty?
  end

  it 'has an author orcid' do
    sse = SPARQL.parse("PREFIX so: <http://schema.org/>
                        PREFIX cm: <https://codemeta.github.io/terms/>
                        PREFIX orcid: <http://orcid.org/>
                        SELECT * WHERE { orcid:0000-0002-2192-403X ?p ?o  }")
    resultSet = @graph.query(sse)
    #resultSet.each do |result|
      #puts result.inspect
      #puts "predicate=#{result.p} object=#{result.o}"
    #end
    refute resultSet.empty?
  end

  it 'has agent' do
    sse = SPARQL.parse("PREFIX so: <http://schema.org/>
                      PREFIX cm: <https://codemeta.github.io/terms/>
                      PREFIX orcid: <http://orcid.org/>
                      SELECT * WHERE { ?s <http://schema.org/agent> ?o  }")
    resultSet = @graph.query(sse)
    #resultSet.each do |result|
    #  puts result.inspect
    #end
    refute resultSet.empty?
  end

   describe "when checking schema.org predicates" do
     queryStr = "PREFIX so: <http://schema.org/>
                 PREFIX cm: <https://codemeta.github.io/terms/>
                 PREFIX orcid: <http://orcid.org/>
                 SELECT * WHERE { ?s <http://schema.org/JSONTerm> ?o  }"
     # Check statements with schema.org based predicate
     predicates = ["codeRepository", "dateCreated", "dateModified", "datePublished",
                  "description", "downloadUrl", "keywords", "license",
                 "programmingLanguage", "publisher", "requirements", "suggests",
                 "version", "URL", "name"]
     predicates.each do |thisPredicate|
       it 'has schema.org predicates' do
         thisQueryStr = queryStr.gsub("JSONTerm", thisPredicate)
         sse = SPARQL.parse(thisQueryStr)
         resultSet = @graph.query(sse)
         #resultSet.each do |result|
           #puts result.inspect
         #nd
         refute resultSet.empty?
       end
     end

   end

   describe "when checking codemeta schema" do
     queryStr = "PREFIX so: <http://schema.org/>
                 PREFIX cm: <https://codemeta.github.io/terms/>
                 PREFIX orcid: <http://orcid.org/>
                 SELECT * WHERE { ?s <https://codemeta.github.io/terms/JSONTerm> ?o  }"
     # Check statements with codemeta namespaced predicate
     predicates = ["buildInstructions", "contIntegration", "docsCoverage",
       "embargoDate", "function", "funding", "inputs", "interactionMethod",
       "isAutomatedBuild", "issueTracker", "outputs", "readme", "relatedLink",
       "relatedPublications", "relationship", "softwareCitation", "softwarePaperCitation",
       "testCoverage", "uploadedBy", "zippedCode"]
     predicates.each do |thisPredicate|
       it 'has codemeta predicates' do
         thisQueryStr = queryStr.gsub("JSONTerm", thisPredicate)
         sse = SPARQL.parse(thisQueryStr)
         resultSet = @graph.query(sse)
         #resultSet.each do |result|
          # puts result.inspect
         #end
         refute resultSet.empty?
       end
     end
   end
end
