require 'spec_helper'

describe 'VaingloryAPI spec', vcr: true do
  let(:valid_api_key) { 'valid_api_key' }
  let(:client) { VaingloryAPI.new(valid_api_key) }

  context 'metadata' do
    it 'returns an error with an invalid API key' do
      VCR.use_cassette('api_key', record: :new_episodes) do
        response = VaingloryAPI.new('invalid-api-key').samples
        expects_error_response(response, 401)
      end
    end

    it 'returns success and API rate limit information' do
      VCR.use_cassette('samples', record: :new_episodes) do
        response = client.samples

        expects_success_response(response)
        expect(response.rate_limit).to be_a(Integer)
        expect(response.rate_remaining).to be_a(Integer)
        expect(response.rate_reset).to be_a(Integer)
      end
    end

    it 'supports multiple regions' do
      VCR.use_cassette('samples', record: :new_episodes) do
        %w(eu sa ea sg).each do |region|
          response = VaingloryAPI.new(valid_api_key, region).samples
          expects_success_response(response)
        end
      end
    end
  end

  context '#status' do
    it 'returns a status object' do
      VCR.use_cassette('status') do
        response = client.status

        expects_success_response(response)
        expect(response.data.type).to be_a(String)
        expect(response.data.id).to be_a(String)
        expect(response.data.attributes.releasedAt).to be_a(String)
        expect(response.data.attributes.version).to be_a(String)
      end
    end
  end

  context '#players' do
    it 'returns an array of players with a valid name' do
      VCR.use_cassette("players", record: :new_episodes) do
        response = client.players('boombastic04')

        expects_success_response(response)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to be > 0
      end
    end

    it 'returns error with an valid name' do
      VCR.use_cassette('players', record: :new_episodes) do
        response = client.players('TheRealKrul')
        expects_error_response(response)
      end
    end
  end

  context '#player' do
    it 'returns a player with a valid ID' do
      VCR.use_cassette("players", record: :new_episodes) do
        response = client.player("6abb30de-7cb8-11e4-8bd3-06eb725f8a76")
        player = response.data

        expects_success_response(response)
        expect(player.type).to eq 'player'
        expect(player.id).to eq '6abb30de-7cb8-11e4-8bd3-06eb725f8a76'
        expect(player.attributes.createdAt).to eq '2017-03-15T19:46:43Z'
        expect(player.attributes.name).to eq 'boombastic04'
        expect(player.attributes.shardId).to eq 'na'
        expect(player.attributes.stats.level).to eq 30
        expect(player.attributes.stats.lifetimeGold).to eq 18087.5
        expect(player.attributes.stats.lossStreak).to eq 1
        expect(player.attributes.stats.played).to eq 1564
        expect(player.attributes.stats.played_ranked).to eq 155
        expect(player.attributes.stats.winStreak).to eq 0
        expect(player.attributes.stats.wins).to eq 859
        expect(player.attributes.stats.xp).to eq 175450
        expect(player.attributes.titleId).to eq 'semc-vainglory'
      end
    end

    it 'returns an error with an invalid ID' do
      VCR.use_cassette('players', record: :new_episodes) do
        response = client.player('invalid-id')
        expects_error_response(response)
      end
    end
  end

  context '#matches' do
    it 'returns an array of matches' do
      VCR.use_cassette('matches', record: :new_episodes) do
        response = client.matches

        expects_success_response(response)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to be > 0
      end
    end

    it 'returns the number of matches specified by a filter' do
      VCR.use_cassette('matches', record: :new_episodes) do
        response = client.matches('page[limit]' => 1)

        expects_success_response(response)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to eq 1
      end
    end

    it 'returns an array of matches with valid player name filter' do
        response = client.matches({'filter[playerNames]' => 'KngBEAZT'})
      VCR.use_cassette('matches', record: :new_episodes) do

        expects_success_response(response)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to be > 0
      end
    end

    it 'returns an error with invalid player name filter' do
      VCR.use_cassette('matches', record: :new_episodes) do
        response = client.matches('filter[playerNames]' => 'TheRealKrul')
        expects_error_response(response)
      end
    end
  end

  context '#match' do
    it 'returns a match with a valid ID' do
        response = client.match("37f94e56-1360-11e7-a250-062445d3d668")
      VCR.use_cassette('match', record: :new_episodes) do
        game_match = response.data

        expects_success_response(response)
        expect(game_match.type).to eq 'match'
        expect(game_match.id).to eq '37f94e56-1360-11e7-a250-062445d3d668'
        expect(game_match.attributes.createdAt).to eq '2017-03-28T02:42:53Z'
        expect(game_match.attributes.duration).to eq 924
        expect(game_match.attributes.gameMode).to eq 'casual'
        expect(game_match.attributes.patchVersion).to eq ''
        expect(game_match.attributes.shardId).to eq 'na'
        expect(game_match.attributes.stats.endGameReason).to eq 'victory'
        expect(game_match.attributes.stats.queue).to eq 'casual'
        expect(game_match.attributes.titleId).to eq 'semc-vainglory'
        expect(game_match.relationships.assets.data).to be_a(Array)
        expect(game_match.relationships.assets.data[0].type).to eq 'asset'
        expect(game_match.relationships.assets.data[0].id).to eq '935cc70c-1362-11e7-9a29-0242ac110009'
        expect(game_match.relationships.rosters.data).to be_a(Array)
        expect(game_match.relationships.rosters.data.length).to eq 2
        expect(game_match.relationships.rounds.data).to be_a(Array)
        expect(game_match.relationships.rounds.data.length).to eq 0
      end
    end

    it 'returns an error with an invalid ID' do
      VCR.use_cassette('match', record: :new_episodes) do
        response = client.match('invalid-id')
        expects_error_response(response)
      end
    end
  end

  context 'telemetry' do
    it 'returns telemetry data for a valid URL' do
      VCR.use_cassette('telemetry', record: :new_episodes) do
        response = client.telemetry('https://gl-prod-us-east-1.s3.amazonaws.com/assets/semc-vainglory/na/2017/03/28/03/07/b0bb7faf-1363-11e7-b11e-0242ac110006-telemetry.json')

        expects_success_response(response)
        expect(response.data).to be_a Array
        expect(response.data[0].time).to eq '2017-03-28T03:02:09+0000'
        expect(response.data[0].type).to eq 'PlayerFirstSpawn'
        expect(response.data[0].payload.Team).to eq 'Left'
        expect(response.data[0].payload.Actor).to eq '*Ringo*'

      end
    end
  end

  context '#teams' do
    it 'raises error' do
      expect { client.teams }.to raise_error(NotImplementedError)
    end
  end

  context '#team' do
    it 'raises error' do
      expect { client.team('team_id') }.to raise_error(NotImplementedError)
    end
  end

  context '#link' do
    it 'raises error' do
      expect { client.link('link_id') }.to raise_error(NotImplementedError)
    end
  end

  def expects_success_response(response)
    expect(response.code).to eq 200
    expect(response.success?).to be true
  end

  def expects_error_response(response, response_code = 404)
    expect(response.code).to eq response_code
    expect(response.success?).to be false
  end
end
