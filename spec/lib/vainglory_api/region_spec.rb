require 'spec_helper'

describe VaingloryAPI::Region do
  describe '#abbreviation' do
    it 'returns the short name' do
      region = subject.new('ea')
      expect(region.abbreviation).to eq region.short_name
    end
  end

  describe '#eql?' do
    let(:region) { VaingloryAPI::Region['na'] }

    it 'returns TRUE when all attributes match' do
      expect(region.eql?(VaingloryAPI::Region.new('na'))).to be true
    end

    it 'returns FALSE when any attribute does not match' do
      expect(region.eql?(VaingloryAPI::Region.new('eu'))).to be false
    end
  end

  describe '.new' do
    it 'instantiates a Region from the DB matching the identifier' do
      expect(subject.new('North America')).to be_an_instance_of(subject)
    end

    it 'find a region by short name (abbreviation)' do
      expect(subject.new('eu')).to be_an_instance_of(subject)
    end

    it 'raises an error when region identifier not found' do
      expect { subject.new('QQ') }.to raise_error VaingloryAPI::RegionNameError
    end
  end

  describe '.find' do
    it 'aliases .new' do
      expect(subject.find('na')).to eql subject.new('na')
    end
  end

  describe '.[]' do
    it 'aliases .new' do
      expect(subject['na']).to eql subject.new('na')
    end
  end

  describe '.valid_short_name?' do
    it 'returns TRUE when the short name is found' do
      expect(subject.valid_short_name?('tournament-sa')).to be true
    end

    it 'returns FALSE when the short name is not found' do
      expect(subject.valid_short_name?('QQ')).to be false
    end
  end

  describe '.detect_region_info' do
    it 'returns an Array of region data when identifier is found' do
      region_info = subject.detect_region_info('na')
      expect(region_info).to be_an_instance_of(Array)
    end

    it 'returns nil when identifier is not found' do
      region_info = subject.detect_region_info('QQ')
      expect(region_info).to be_nil
    end
  end
end
