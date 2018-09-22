module IAmICan
  module Can
    def can?
      #
    end

    def cannot?
      #
    end

    def can!
      #
    end

    def can_every?
      #
    end

    def can_every!
      #
    end
  end

  # === End of MainMethods ===

  module Can::SecondaryMethods
    #

    Can.include self
  end
end
