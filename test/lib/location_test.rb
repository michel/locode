require_relative '../test_helper'

describe Locode::Location do
  describe '.new' do
    it 'must return a valid Location for valid parameters' do
      location_attributes = {
          country_code: 'US',
          city_code: 'NYC',
          full_name: 'New York',
          full_name_without_diacritics: 'New York',
          subdivision: 'NY',
          function_classifier: '12345---',
          status: 'AI',
          date: '0401',
          iata_code: '',
          coordinates: '4042N 07400W'
      }
      location = Locode::Location.new(location_attributes)

      assert location.valid?
    end

    it 'returns an invalid Location object for invalid parameters' do
      location_attributes = {
          foo: 'bar'
      }
      location = Locode::Location.new(location_attributes)

      refute location.valid?
    end
  end

  describe 'to_json' do
    let(:location) { Locode::Location.new({
                                              country_code: 'US',
                                              city_code: 'NYC',
                                              full_name: 'New York',
                                              full_name_without_diacritics: 'New York',
                                              subdivision: 'NY',
                                              function_classifier: '12345---',
                                              status: 'AI',
                                              date: '0401',
                                              iata_code: '',
                                              coordinates: '4042N 07400W'
                                          }) }

    it 'should return a json output' do
      json = MultiJson.load(location.to_json)
      json['country_code'].must_equal location.country_code
      json['city_code'].must_equal location.city_code
      json['full_name'].must_equal location.full_name
      json['full_name_without_diacritics'].must_equal location.full_name_without_diacritics
      json['subdivision'].must_equal location.subdivision
      json['function_classifier'].must_equal location.function_classifier
      json['status'].must_equal location.status.to_s
      json['date'].must_equal location.date
      json['iata_code'].must_equal location.iata_code
      json['coordinates'].must_equal location.coordinates
    end
  end

  describe 'to_h' do
    let(:attributes) { {
        country_code: 'US',
        city_code: 'NYC',
        full_name: 'New York',
        full_name_without_diacritics: 'New York',
        subdivision: 'NY',
        function_classifier: '12345---',
        status: 'AI',
        date: '0401',
        iata_code: '',
        coordinates: '4042N 07400W'
    } }
    let(:location) { Locode::Location.new(attributes) }

    it 'should return a hash' do
      hash = location.to_h
      hash.must_be_instance_of Hash
      hash[:subdivision].must_equal location.subdivision
      hash[:coordinates].must_equal location.coordinates
    end
  end

  describe 'downcase_names' do
    before(:each) do
      @location = Locode::Location.new full_name: 'Full_Name', full_name_without_diacritics: 'Full_name_without_Diacritics'
      @location.alternative_full_names = 'Alternative_full_Names'
      @location.alternative_full_names_without_diacritics = 'Alternative_full_names_without_Diacritics'
    end

    it 'should include the full name' do
      @location.downcase_names.must_include 'full_name'
    end

    it 'should include the full name without diacritics' do
      @location.downcase_names.must_include 'full_name_without_diacritics'
    end

    it 'should include the alternative full name' do
      @location.downcase_names.must_include 'alternative_full_names'
    end

    it 'should include the alternative full name without diacritics' do
      @location.downcase_names.must_include 'alternative_full_names_without_diacritics'
    end
  end
end