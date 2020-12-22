module GamificationHelper
  def in_gamified_context?(user)
    gamified_organization? || gamified_user?(user)
  end

  def gamified_organization?
    Organization.current.gamification_enabled?
  end

  def gamified_user?(user)
    UserStats.game_mode_enabled_for? user
  end
end
