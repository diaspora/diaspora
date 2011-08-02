require 'spec_helper'
require 'extlib/inflection'

describe Extlib::Inflection do
  describe "#classify" do
    it 'classifies data_mapper as DataMapper' do
      Extlib::Inflection.classify('data_mapper').should == 'DataMapper'
    end

    it "classifies enlarged_testes as EnlargedTestis" do
      Extlib::Inflection.classify('enlarged_testes').should == 'EnlargedTestis'
    end

    it "singularizes string first: classifies data_mappers as egg_and_hams as EggAndHam" do
      Extlib::Inflection.classify('egg_and_hams').should == 'EggAndHam'
    end
  end

  describe "#camelize" do
    it 'camelizes data_mapper as DataMapper' do
      Extlib::Inflection.camelize('data_mapper').should == 'DataMapper'
    end

    it "camelizes merb as Merb" do
      Extlib::Inflection.camelize('merb').should == 'Merb'
    end

    it "camelizes data_mapper/resource as DataMapper::Resource" do
      Extlib::Inflection.camelize('data_mapper/resource').should == 'DataMapper::Resource'
    end

    it "camelizes data_mapper/associations/one_to_many as DataMapper::Associations::OneToMany" do
      Extlib::Inflection.camelize('data_mapper/associations/one_to_many').should == 'DataMapper::Associations::OneToMany'
    end
  end

  describe "#underscore" do
    it 'underscores DataMapper as data_mapper' do
      Extlib::Inflection.underscore('DataMapper').should == 'data_mapper'
    end

    it 'underscores Merb as merb' do
      Extlib::Inflection.underscore('Merb').should == 'merb'
    end

    it 'underscores DataMapper::Resource as data_mapper/resource' do
      Extlib::Inflection.underscore('DataMapper::Resource').should == 'data_mapper/resource'
    end

    it 'underscores Merb::BootLoader::Rackup as merb/boot_loader/rackup' do
      Extlib::Inflection.underscore('Merb::BootLoader::Rackup').should == 'merb/boot_loader/rackup'
    end
  end

  describe "#humanize" do
    it 'replaces _ with space: humanizes employee_salary as Employee salary' do
      Extlib::Inflection.humanize('employee_salary').should == 'Employee salary'
    end

    it "strips _id endings: humanizes author_id as Author" do
      Extlib::Inflection.humanize('author_id').should == 'Author'
    end
  end

  describe "#demodulize" do
    it 'demodulizes module name: DataMapper::Inflector => Inflector' do
      Extlib::Inflection.demodulize('DataMapper::Inflector').should == 'Inflector'
    end

    it 'demodulizes module name: A::B::C::D::E => E' do
      Extlib::Inflection.demodulize('A::B::C::D::E').should == 'E'
    end
  end

  describe "#tableize" do
    it 'pluralizes last word in snake_case strings: fancy_category => fancy_categories' do
      Extlib::Inflection.tableize('fancy_category').should == 'fancy_categories'
    end

    it 'underscores CamelCase strings before pluralization: enlarged_testis => enlarged_testes' do
      Extlib::Inflection.tableize('enlarged_testis').should == 'enlarged_testes'
    end

    it 'underscores CamelCase strings before pluralization: FancyCategory => fancy_categories' do
      Extlib::Inflection.tableize('FancyCategory').should == 'fancy_categories'
    end

    it 'underscores CamelCase strings before pluralization: EnlargedTestis => enlarged_testes' do
      Extlib::Inflection.tableize('EnlargedTestis').should == 'enlarged_testes'
    end

    it 'replaces :: with underscores: Fancy::Category => fancy_categories' do
      Extlib::Inflection.tableize('Fancy::Category').should == 'fancy_categories'
    end

    it 'underscores CamelCase strings before pluralization: Enlarged::Testis => enlarged_testes' do
      Extlib::Inflection.tableize('Enlarged::Testis').should == 'enlarged_testes'
    end

  end

  describe "#foreign_key" do
    it 'adds _id to downcased string: Message => message_id' do
      Extlib::Inflection.foreign_key('Message').should == 'message_id'
    end

    it "demodulizes string first: Admin::Post => post_id" do
      Extlib::Inflection.foreign_key('Admin::Post').should == 'post_id'
    end
  end
end
