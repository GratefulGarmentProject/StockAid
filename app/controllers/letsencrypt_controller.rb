class LetsencryptController < ApplicationController
  skip_before_action :authenticate_user!

  def letsencrypt
    render text: "GHsKETOLaQ3HUHjD4rJMzhjRnzM8K1Z_y6gXJcszipQ.xQk3L_ZooytfqxYnB78MxA3nMkWHp7bd6j8jAExcZMs"
  end
end
