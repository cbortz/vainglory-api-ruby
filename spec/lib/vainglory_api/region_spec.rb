require 'spec_helper'

describe VaingloryAPI::Region do
  describe '#abbreviation' do
    it 'returns the short name' do
      region = subject.find('ea')
      expect(region.abbreviation).to eq region.short_name
    end
  end

  describe '.new' do
    it 'does not allow instantiation publicly' do
      expect { subject.new(nil, nil, nil) }.to raise_error NoMethodError
    end
  end

  describe '.find' do
    it 'finds a region by name' do
      expect(subject.find('North America')).to be_an_instance_of(subject)
    end

    it 'find a region by short name (abbreviation)' do
      expect(subject.find('eu')).to be_an_instance_of(subject)
    end

    it 'raises an error when region not found' do
      expect { subject.find('QQ') }.to raise_error VaingloryAPI::RegionNameError
    end
  end

  describe '.[]' do
    it 'aliases .find' do
      expect(subject['na']).to eql subject.find('na')
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

  describe '.validate_short_name!' do
    it 'returns TRUE when the short name is found' do
      expect(subject.validate_short_name!('tournament-sg')).to be true
    end

    it 'raises an error when the short name is not found' do
      expect { subject.validate_short_name!('QQ') }.to raise_error VaingloryAPI::RegionNameError
    end
  end
end
