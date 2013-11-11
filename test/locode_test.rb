require_relative 'test_helper'

describe Locode do
  describe '.find_by_locode' do
    it 'should return the correct location' do
      locode = 'DE HAM'
      location = Locode.find_by_locode(locode).first

      location.locode.must_equal locode
    end
  end

  describe '.find_by_name' do
    it 'should find the location for a given name' do
      name = 'Hamburg'
      location = Locode.find_by_name(name).first
      location.full_name.must_equal name
    end
  end

  describe 'find locations by country for function' do

    describe 'invalid calls' do
      it 'returns an empty array when country code is empty' do
        Locode.find_by_country_and_function(nil, 1).must_be_empty
      end

      it 'returns an empty array when country code is not a string' do
        Locode.find_by_country_and_function(12, 1).must_be_empty
      end

      it 'returns an empty array when country code is not 2 chars long' do
        Locode.find_by_country_and_function('ABC', 1).must_be_empty
        Locode.find_by_country_and_function('A', 1).must_be_empty
      end

      it 'returns an empty array when country code is not in upper case' do
        Locode.find_by_country_and_function('aa', 1).must_be_empty
        Locode.find_by_country_and_function('a', 1).must_be_empty
      end

      it 'returns an empty array when function is not a possible function' do
        Locode.find_by_country_and_function('AB', 9).must_be_empty
        Locode.find_by_country_and_function('AB', 0).must_be_empty
        Locode.find_by_country_and_function('AB', nil).must_be_empty
        Locode.find_by_country_and_function('AB', ':C').must_be_empty
        Locode.find_by_country_and_function('AB', ':b').must_be_empty
      end
    end

    describe 'valid calls' do
      let(:seaport) { Locode::Location.new country_code: 'BE', full_name: 'Antwerp', function_classifier: [1] }
      let(:airport) { Locode::Location.new country_code: 'BE', full_name: 'Brussels', function_classifier: [4] }
      let(:railstation) { Locode::Location.new country_code: 'NL', full_name: 'Venlo', function_classifier: [2] }
      let(:locations) { [] }

      before(:each) do
        Locode.const_set :ALL_LOCATIONS, locations
      end

      describe 'without limit' do
        before(:each) do
          locations << seaport << airport << railstation
        end

        it 'excepts :B as a valid function' do
          Locode.find_by_country_and_function('AB', ':B').must_be_empty
        end

        it 'finds all locations for Belgium as seaport' do
          locations = Locode.find_by_country_and_function('BE', 1)
          locations.count.must_equal 1
          locations.must_include seaport
          locations.wont_include airport
          locations.wont_include railstation
        end

        it 'finds all railstations in the Netherlands' do
          locations = Locode.find_by_country_and_function('NL', 2)
          locations.count.must_equal 1
          locations.must_include railstation
          locations.wont_include airport
          locations.wont_include seaport
        end
      end

      describe 'with limit' do
        before(:each) do
          locations << railstation << railstation << railstation
        end

        [1, 2].each do |limit|
          it "returns array with the #{limit} location" do
            locations = Locode.find_by_country_and_function('NL', 2, limit)
            locations.count.must_equal limit
          end
        end
      end
    end

  end

  describe 'find city scoped by country' do

    describe 'invalid calls' do
      it 'returns an empty array when country code is empty' do
        Locode.find_by_country_and_name(nil, 1).must_be_empty
      end

      it 'returns an empty array when country code is not a string' do
        Locode.find_by_country_and_name(12, 1).must_be_empty
      end

      it 'returns an empty array when country code is not 2 chars long' do
        Locode.find_by_country_and_name('ABC', 1).must_be_empty
        Locode.find_by_country_and_name('A', 1).must_be_empty
      end

      it 'returns an empty array when country code is not in upper case' do
        Locode.find_by_country_and_name('aa', 1).must_be_empty
        Locode.find_by_country_and_name('a', 1).must_be_empty
      end

      it 'returns an empty array when search string is not a string' do
        Locode.find_by_country_and_name('AB', 9).must_be_empty
        Locode.find_by_country_and_name('AB', nil).must_be_empty
        Locode.find_by_country_and_name('AB', :test).must_be_empty
        Locode.find_by_country_and_name('AB', 1.0).must_be_empty
      end
    end

    describe 'valid calls' do
      let(:antwerp) { create_location 'BE', 'Antwerp' }
      let(:brussels) { create_location 'BE', 'Brussels' }
      let(:venlo) { create_location 'NL', 'Venlo' }
      let(:locations) { [] }

      before(:each) do
        Locode.const_set :ALL_LOCATIONS, locations
      end

      describe 'without limit' do
        before(:each) do
          locations << antwerp << brussels << venlo
        end

        it 'finds all locations for Belgium as seaport' do
          locations = Locode.find_by_country_and_name('BE', 'Antwerp')
          locations.count.must_equal 1
          locations.must_include antwerp
          locations.wont_include brussels
          locations.wont_include venlo
        end

        it 'finds all railstations in the Netherlands' do
          locations = Locode.find_by_country_and_name('NL', 'V')
          locations.count.must_equal 1
          locations.must_include venlo
          locations.wont_include brussels
          locations.wont_include antwerp
        end
      end

      describe 'with limit' do
        before(:each) do
          locations << venlo << venlo << venlo
        end

        [1, 2].each do |limit|
          it "returns array with the #{limit} location" do
            locations = Locode.find_by_country_and_name('NL', 'Ven', limit)
            locations.count.must_equal limit
          end
        end
      end

      def create_location(country, name)
        location = Locode::Location.new country_code: country, full_name: name, full_name_without_diacritics: name
        location.alternative_full_names = [name]
        location.alternative_full_names_without_diacritics = [name]
        return location
      end
    end
  end

  describe 'find locations by name for function' do

    describe 'invalid calls' do
      it 'returns an empty array when search string is empty' do
        Locode.find_by_name_and_function(nil, 1).must_be_empty
      end

      it 'returns an empty array when search string is not a string' do
        Locode.find_by_name_and_function(12, 1).must_be_empty
      end

      it 'returns an empty array when function is not a possible function' do
        Locode.find_by_name_and_function('AB', 9).must_be_empty
        Locode.find_by_name_and_function('AB', 0).must_be_empty
        Locode.find_by_name_and_function('AB', nil).must_be_empty
        Locode.find_by_name_and_function('AB', ':C').must_be_empty
        Locode.find_by_name_and_function('AB', ':b').must_be_empty
      end
    end

    describe 'valid calls' do
      let(:antwerp) { create_location 'BE', 'Antwerp'}
      let(:brussels) { create_location 'BE', 'Brussels' }
      let(:venlo) { create_location 'NL', 'Venlo'}
      let(:locations) { [] }

      before(:each) do
        Locode.const_set :ALL_LOCATIONS, locations
      end

      describe 'without limit' do
        before(:each) do
          locations << antwerp << brussels << venlo
        end

        it 'finds all locations for Antwerp as seaport' do
          locations = Locode.find_by_name_and_function('Antwerp', 1)
          locations.count.must_equal 1
          locations.must_include antwerp
          locations.wont_include brussels
          locations.wont_include venlo
        end


        it 'filters on function identifier' do
          locations = Locode.find_by_name_and_function('Antwerp', 2)
          locations.count.must_equal 0
          locations = Locode.find_by_name_and_function('Antwerp', 1)
          locations.count.must_equal 1
        end


      end
    end

    def create_location(country, name, function = 1)
      location = Locode::Location.new country_code: country, full_name: name, full_name_without_diacritics: name, function_classifier: [function]
      location.alternative_full_names = [name]
      location.alternative_full_names_without_diacritics = [name]
      return location
    end

  end
end

