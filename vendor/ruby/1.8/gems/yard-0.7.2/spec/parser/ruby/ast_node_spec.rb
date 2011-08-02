require File.join(File.dirname(__FILE__), '..', '..', 'spec_helper')
require 'pp'
require 'stringio'

include YARD::Parser::Ruby

describe YARD::Parser::Ruby::AstNode do
  describe "#jump" do
    it "should jump to the first specific inner node if found" do
      ast = s(:paren, s(:paren, s(:params, s(s(:ident, "hi"), s(:ident, "bye")))))
      ast.jump(:params)[0][0].type.should equal(:ident)
    end

    it "should return the original ast if no inner node is found" do
      ast = s(:paren, s(:list, s(:list, s(s(:ident, "hi"), s(:ident, "bye")))))
      ast.jump(:params).object_id.should == ast.object_id
    end
  end
  
  describe '#pretty_print' do
    it "should show a list of nodes" do
      obj = YARD::Parser::Ruby::RubyParser.parse("# x\nbye", "x").ast
      out = StringIO.new
      PP.pp(obj, out)
      out.string.should == "s(s(:var_ref,\n" +
        "      s(:ident, \"bye\", line: 2..2, source: 4..6),\n" +
        "      docstring: \"x\",\n" +
        "      line: 2..2,\n" +
        "      source: 4..6))\n"
    end
  end
end if HAVE_RIPPER
