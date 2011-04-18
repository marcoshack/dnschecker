require 'rubygems'
require 'net/dns/resolver'
require 'lib/dnschecker'

class Dnschecker
  def initialize(*args)
    @resolver = Net::DNS::Resolver.new(:log_file => '/dev/null', :retry => 1)
  end

  def check_name(name)
    begin
      answer = @resolver.query(name).answer
      if !answer.empty?
        show_result "OK", name, answer_address(answer[0]), answer[0].type
      else
        show_result "NOK", name, "No answer for this name"
      end
    rescue Net::DNS::Resolver::NoResponseError
      show_result "ERROR", name, "Timeout"
    rescue Exception => e
      show_result "ERROR", name, e.message
    end
  end
  
  def domain_list_from_file(filename)
    domain_list = []
    File.readlines(filename).each do |domain|
      domain_list << domain.gsub(/\n/,'')
    end
    domain_list
  end
  
  def answer_address(answer)
    if answer.type == "A"
      answer.address.to_s 
    elsif answer.type == "CNAME"
      answer.cname
    end
  end

  def show_result(status, name, message, type = "")
    printf "%-5s\t%-30s\t%-5s\t%-30s\n", status, name, type, message
  end
end
