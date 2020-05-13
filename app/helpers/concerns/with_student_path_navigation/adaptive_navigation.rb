module WithStudentPathNavigation
  class AdaptiveNavigation < ContinueNavigation
    def sibling_for(navigable)
      navigable.next_suggested_item_for(current_user)
    end
  end
end
