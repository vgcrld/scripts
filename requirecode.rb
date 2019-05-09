
module MyTestModule

  require 'forwardable'

  class RecordCollection
    attr_accessor :records
    extend Forwardable
    def_delegator :@records, :[], :record_number
  end

  rr = RecordCollection.new
  rr.records = [ "test", 1, 20, Time.new ]
  p rr.record_number(3)

end
