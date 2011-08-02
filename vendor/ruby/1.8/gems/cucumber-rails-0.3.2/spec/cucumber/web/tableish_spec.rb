# -*- encoding: utf-8 -*-

require File.expand_path(File.dirname(__FILE__) + "/../../spec_helper")

def World(*a); end
require 'cucumber/web/tableish'

module Cucumber
  module Web
    describe Tableish do
      include Tableish

      unless RUBY_PLATFORM =~ /java/
        it "should convert a table" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
              </tr>
              <tr>
                <td>cucumber</td>
                <td>aslak</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            %w{tool dude},
            %w{webrat bryan},
            %w{cucumber aslak}
          ]
        end

        it "should size to the first row" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
                <td>crapola</td>
              </tr>
              <tr>
                <td>cucumber</td>
                <td>aslak</td>
                <td>gunk</td>
                <td>filth</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['tool',     'dude',],
            ['webrat',   'bryan'],
            ['cucumber', 'aslak']
          ]
        end

        it "should pad with empty Strings if some rows are shorter" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <th>tool</th>
                <th>dude</th>
              </tr>
              <tr>
                <td>webrat</td>
                <td>bryan</td>
              </tr>
              <tr>
                <td>cucumber</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            %w{tool dude},
            %w{webrat bryan},
            ['cucumber', '']
          ]
        end

        it "should handle colspan and rowspan" do
          html = <<-HTML
            <table id="tools">
              <tr>
                <td rowspan="4">a</td>
                <td>b</td>
                <td>c</td>
                <td>d</td>
              </tr>
              <tr>
                <td colspan="3">e</td>
              </tr>
              <tr>
                <td rowspan="2" colspan="2">f</td>
                <td>g</td>
              </tr>
              <tr>
                <td>h</td>
              </tr>
            </table>
          HTML

          _tableish(html, 'table#tools tr', 'td,th').should == [
            ['a', 'b', 'c', 'd'],
            ['',  'e', '',  '' ],
            ['',  'f', '',  'g' ],
            ['',  '',  '',  'h' ],
           ]
        end

        it "should convert a dl" do
          html = <<-HTML
            <dl id="tools">
              <dt>webrat</dt>
              <dd>bryan</dd>
              <dt>cucumber</dt>
              <dd>aslak</dd>
            </dl>
          HTML

          _tableish(html, 'dl#tools dt', lambda{|dt| [dt, dt.next.next]}).should == [
            %w{webrat bryan},
            %w{cucumber aslak}
          ]
        end

        it "should convert a ul" do
          html = <<-HTML
            <ul id="phony">
              <li>nope</li>
            </ul>

            <ul id="yes">
              <li>webrat</li>
              <li>bryan</li>
              <li>cucumber</li>
              <li>aslak</li>
            </ul>
          HTML

          _tableish(html, 'ul#yes li', lambda{|li| [li]}).should == [
            %w{webrat},
            %w{bryan},
            %w{cucumber},
            %w{aslak},
          ]
        end

        it "should do complex shit" do
          html = <<-HTML
            <form method="post" action="/invoices/10/approve" class="button-to">
              <div>
                <input id="approve_invoice_10" type="submit" value="Approve" />
                <input name="authenticity_token" type="hidden" value="WxKGVy3Y5zcvFEiFe66D/odoc3CicfMdAup4vzQfiZ0=" />
                <span>Hello&nbsp;World<span>
              </div>
            </form>
            <form method="post" action="/invoices/10/delegate" class="button-to">
              <div>
                <input id="delegate_invoice_10" type="submit" value="Delegate" />
                <input name="authenticity_token" type="hidden" value="WxKGVy3Y5zcvFEiFe66D/odoc3CicfMdAup4vzQfiZ0=" />
                <span>Hi There<span>
              </div>
            </form>
          HTML

          selectors = lambda do |form|
            [
              form.css('div input:nth-child(1)').first.attributes['value'],
              form.css('span').first.text.gsub(/\302\240/, ' ')
            ]
          end

          _tableish(html, 'form', selectors).should == [
            ['Approve', "Hello World"],
            ['Delegate', 'Hi There']
          ]
        end
      end
    end
  end
end
