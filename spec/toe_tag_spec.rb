require 'toe_tag'

describe ToeTag do
  
  let(:error_a) { Class.new StandardError }
  let(:error_b) { Class.new StandardError }
  let(:error_c) { Class.new StandardError }
  let(:error_oddball) { Class.new StandardError }

  let(:error_group) { ToeTag::CategorySpec.new(error_a, error_b, error_c) }
  
  describe ToeTag::CategorySpec do

    it "should capture exceptions from any class it is composed from" do
      expect {
        begin 
          raise error_a
        rescue error_group
        end
        begin
          raise error_b
        rescue error_group
        end
        begin
          raise error_c
        rescue error_group
        end
      }.not_to raise_error
      expect {
        begin
          raise error_oddball
        rescue error_group
        end
      }.to raise_error(error_oddball)
    end

    context ".category" do

      it "should look up exception types by name, skipping nonexistent ones" do
        grouping = ToeTag.category %w[NameError KeyError BogusError]
        expect(grouping.exceptions.length).to eql 2
        expect(grouping === NameError.new).to eql true
      end

    end

  end

  describe ToeTag::ProcSpec do
    
    it "should capture exceptions that return true from a given proc" do
      catcher = ToeTag::ProcSpec.new(->(e){ e.message == "not spurious" })
      expect {
        begin
          raise error_a, "not spurious"
        rescue catcher
        end
      }.not_to raise_error
      expect {
        begin
          raise error_a, "totally spurious"
        rescue catcher
        end
      }.to raise_error(error_a)
    end

  end

  describe ToeTag::MessageSpec do
    
    it "should capture exceptions with a given message substring" do
      catcher = ToeTag::MessageSpec.new("spurious")
      expect {
        begin
          raise error_a, "a spurious error"
        rescue catcher
        end
      }.not_to raise_error
      expect {
        begin
          raise error_a, "a serious error"
        rescue catcher
        end
      }.to raise_error
    end

    context "combined with ExceptionCategory" do
      
      it "should capture exceptions within a set with a given message substring" do
        catcher = ToeTag.category(error_group).with_message("spurious")
        expect {
          begin
            raise error_a, "a spurious error"
          rescue catcher
          end
        }.not_to raise_error
        expect {
          begin
            raise error_oddball, "a spurious error, outside the group"
          rescue catcher
          end
        }.to raise_error(error_oddball)
        expect {
          begin
            raise error_b, "a serious error"
          rescue catcher
          end
        }.to raise_error(error_b)
      end

    end

    context "using the Exception extensions" do

      it "should catch errors by message" do
        catcher = StandardError.with_message(/catch|retrieve|fetch/)
        expect {
          begin
            raise "catch me if you can"
          rescue catcher
          end
        }.not_to raise_error
        expect {
          begin
            raise "fail"
          rescue catcher
          end
        }.to raise_error(StandardError)
      end

    end

  end

end
