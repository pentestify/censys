
require 'spec_helper'

describe Censys do
  it 'has a version number' do
    expect(Censys::VERSION).not_to be nil
  end

  it 'can be lazy evaluated' do
    c =  Censys::Api.new
    result =  c.search_ipv4_index("1.1.1.1")

    expect(result).to be_a(Enumerator)
    expect(result.first(3)).to be_a(Array)
    expect(result.first(3).first).to be_a(Hash)
    
  end
 
end
