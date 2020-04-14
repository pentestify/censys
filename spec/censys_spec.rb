
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
 
  it 'can provide certificate results for a domain' do
    c =  Censys::Api.new
    result =  c.search_certificates_index("intrigue.io")

    expect(result).to be_a(Enumerator)
    expect(result.first(1)).to be_a(Array)
    expect(result.first(1).first).to be_a(Hash)

    #puts result.first(1).first
  end

  it 'can provide detailed certificate results for a domain' do
    c =  Censys::Api.new
    result =  c.search_certificates_index("intrigue.io")

    expect(result).to be_a(Enumerator)
    expect(result.first(1)).to be_a(Array)
    
    short_cert = result.first(1).first
    
    expect(short_cert).to be_a(Hash)

    fp = short_cert["parsed"]["fingerprint_sha256"]
    puts "getting details for fingeprint with hash #{fp}"
    
    detailed_cert = c.view_certificate fp
    #puts detailed_cert

    expect(detailed_cert).to be_a(Hash)
    
    
  end


end
