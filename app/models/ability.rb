class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :manage, :all
    end

    can :create, Dataset do |dataset|
      # Publishers can always create a dataset
      true
    end

    can :read, Dataset do |dataset|
      # User can read a dataset if they are a creator, or
      # in an organisation shared by the dataset
      user.id == dataset.creator_id ||
        user.in_organisation(dataset.organisation)
    end

    can :update, Dataset do |dataset|
      # User can update a dataset if they are a creator, or
      # in an organisation shared by the dataset
      user.id == dataset.creator_id ||
        user.in_organisation(dataset.organisation)
    end

    can :delete, Dataset do |dataset|
      # Only sysadmins should be able to delete datasets
      user.admin?
    end

  end
end
