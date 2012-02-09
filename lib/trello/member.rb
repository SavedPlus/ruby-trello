module Trello
  # A Member is a user of the Trello service.
  class Member < BasicData
    register_attributes :id, :username, :full_name, :avatar_id, :bio, :url
    validates_presence_of :id, :username

    class << self
      # Finds a user
      #
      # The argument may be specified as either an _id_ or a _username_.
      def find(id_or_username)
        super(:members, id_or_username)
      end
    end

    # Update the fields of a member.
    #
    # Supply a hash of string keyed data retrieved from the Trello API representing
    # an Member.
    def update_fields(fields)
      attributes[:id]        = fields['id']
      attributes[:full_name] = fields['fullName']
      attributes[:username]  = fields['username']
      attributes[:avatar_id] = fields['avatarHash']
      attributes[:bio]       = fields['bio']
      attributes[:url]       = fields['url']
      self
    end

    # Retrieve a URL to the avatar.
    # 
    # Valid values for options are:
    #   :large (170x170)
    #   :small (30x30)
    def avatar_url(options = { :size => :large })
      size = options[:size] == :size ? 30 : 170
      "https://trello-avatars.s3.amazonaws.com/#{avatar_id}/#{size}.png"
    end

    # Returns a list of the users actions.
    def actions
      Client.get("/members/#{username}/actions").json_into(Action)
    end

    # Returns a list of the boards a member is a part of.
    #
    # The options hash may have a filter key which can have its value set as any
    # of the following values:
    #   :filter => [ :none, :members, :organization, :public, :open, :closed, :all ] # default: :all
    def boards(options = { :filter => :all })
      Client.get("/members/#{username}/boards", options).json_into(Board)
    end

    # Returns a list of cards the member is assigned to.
    #
    # The options hash may have a filter key which can have its value set as any
    # of the following values:
    #    :filter => [ :none, :open, :closed, :all ] # default :open
    def cards(options = { :filter => :open })
      Client.get("/members/#{username}/cards", options).json_into(Card)
    end

    # Returns a list of the organizations this member is a part of.
    #
    # The options hash may have a filter key which can have its value set as any
    # of the following values:
    #   :filter => [ :none, :members, :public, :all ] # default: all
    def organizations(options = { :filter => :all })
      Client.get("/members/#{username}/organizations", options).json_into(Organization)
    end

    # Returns a list of notifications for the user
    def notifications
      Client.get("/members/#{username}/notifications").json_into(Notification)
    end

    def attributes
      @attributes ||= {
        :id          => @id,
        :full_name   => @full_name,
        :username    => @username,
        :gravatar_id => @gravatar_id,
        :bio         => @bio,
        :url         => @url
      }
    end

    def save
      @previously_changed = changes
      @changed_attributes.clear

      # TODO: updating attributes.
    end
  end
end
