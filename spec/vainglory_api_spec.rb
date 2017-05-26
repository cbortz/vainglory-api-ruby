require 'spec_helper'

describe 'VaingloryAPI spec', vcr: true do
  let(:valid_api_key) { 'valid_api_key' }
  let(:client) { VaingloryAPI.new(valid_api_key) }
  let(:cached_matches) { let_cassette('matches') { client.matches } }
  let(:cached_players) { cached_matches.included.select { |i| i.type == 'player' }}

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
        expects_presence(response, :data)
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
        expects_presence(response, :data)
        expect(response.data.type).to be_a(String)
        expect(response.data.id).to be_a(String)
        expect(response.data.attributes.releasedAt).to be_a(String)
        expect(response.data.attributes.version).to be_a(String)
      end
    end
  end

  context '#players' do
    it 'returns an array of players with a valid name' do
      VCR.use_cassette('players', record: :new_episodes) do
        valid_names = cached_players[0, 2].map { |p| p.attributes.name }
        response = client.players(*valid_names)

        expects_success_response(response)
        expects_presence(response, :data, :links, :meta)
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
      VCR.use_cassette('player', record: :new_episodes) do
        cached_player_id = cached_players.first.id
        response = client.player(cached_player_id)

        player = response.data

        expects_success_response(response)
        expects_presence(response, :data, :links, :meta)

        expect(player.type).to eq 'player'
        expect(player.id).to eq cached_player_id
        expect(player.attributes.createdAt).to be_a(String)
        expect(player.attributes.name).to be_a(String)
        expect(player.attributes.shardId).to be_a(String)
        expect(player.attributes.stats.level).to be_a(Integer)
        expect(player.attributes.stats.lifetimeGold).to be_a(Float)
        expect(player.attributes.stats.lossStreak).to be_a(Integer)
        expect(player.attributes.stats.played).to be_a(Integer)
        expect(player.attributes.stats.played_ranked).to be_a(Integer)
        expect(player.attributes.stats.winStreak).to be_a(Integer)
        expect(player.attributes.stats.wins).to be_a(Integer)
        expect(player.attributes.stats.xp).to be_a(Integer)
        expect(player.attributes.titleId).to be_a(String)
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
        expects_presence(response, :data, :included, :links, :meta)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to be > 0
      end
    end

    it 'returns the number of matches specified by a filter' do
      VCR.use_cassette('matches', record: :new_episodes) do
        response = client.matches('page[limit]' => 1)

        expects_success_response(response)
        expects_presence(response, :data, :included, :links, :meta)
        expect(response.data).to be_a(Array)
        expect(response.data.length).to eq 1
      end
    end

    it 'returns an array of matches with valid player name filter' do
      player_name = cached_players.first.attributes.name
      VCR.use_cassette('matches', record: :new_episodes) do
        response = client.matches('filter[playerNames]' => player_name)

        expects_success_response(response)
        expects_presence(response, :data, :included, :links, :meta)
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
      VCR.use_cassette('match', record: :new_episodes) do
        cached_match_id = cached_matches.data.first.id
        response = client.match(cached_match_id)
        game_match = response.data

        expects_success_response(response)
        expects_presence(response, :data, :included, :links, :meta)
        expect(game_match.type).to eq 'match'
        expect(game_match.id).to eq cached_match_id
        expect(game_match.attributes.createdAt).to be_a(String)
        expect(game_match.attributes.duration).to be_a(Integer)
        expect(game_match.attributes.gameMode).to be_a(String)
        expect(game_match.attributes.patchVersion).to be_a(String)
        expect(game_match.attributes.shardId).to be_a(String)
        expect(game_match.attributes.stats.endGameReason).to be_a(String)
        expect(game_match.attributes.stats.queue).to be_a(String)
        expect(game_match.attributes.titleId).to be_a(String)
        expect(game_match.relationships.assets.data).to be_a(Array)
        expect(game_match.relationships.assets.data[0].type).to be_a(String)
        expect(game_match.relationships.assets.data[0].id).to be_a(String)
        expect(game_match.relationships.rosters.data).to be_a(Array)
        expect(game_match.relationships.rosters.data.length).to be_a(Integer)
        expect(game_match.relationships.rounds.data).to be_a(Array)
        expect(game_match.relationships.rounds.data.length).to be_a(Integer)
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
        expect(response.data[0].time).to be_a(String)
        expect(response.data[0].type).to be_a(String)
        expect(response.data[0].payload.Team).to be_a(String)
        expect(response.data[0].payload.Actor).to be_a(String)
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

  def expects_presence(obj, *attrs)
    attrs.each do |attr_name|
      expect(obj.send(attr_name)).to_not be_nil
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

  def let_cassette(cassette_name)
    VCR.use_cassette(cassette_name, record: :new_episodes) do
      yield
    end
  end
end
