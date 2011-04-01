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
        show_result "OK", name, answer_address(answer[0])
      else
        show_result "NOK", name, "No answer for this name"
      end
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
    answer.address.to_s if answer.type == "A"
    answer.cname if answer.type == "CNAME"
  end
  
  def show_result(status, name, message)
    printf "%-5s\t%-30s\t%-50s\n", status, name, message
  end
end
