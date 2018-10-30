module WithStudentPathNavigation
  class FinishNavigation < Navigation
    def button(navigable)
      return unless navigable.is_a? Reading
      content_tag 'a', t(:finish), merge_confirmation_classes(navigable, class: clazz)
    end

    def clazz
      'btn btn-success btn-block'
    end
  end
end
