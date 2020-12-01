mumuki.gamification = (() => {
  class Formula {
    static get QUADRATIC_COEFFICIENT()  { return 25; }
    static get LINEAR_COEFFICIENT()     { return 100; }
    static get CONSTANT_TERM()          { return -125; }
  }

  class LevelProgression {
    constructor(currentExp) {
      this.currentExp = currentExp;
      this.lastEarnedExp = 0;
      this._levelUpShower = this.defaultLevelUpShower;
      this._gainedExperienceShower = this.defaultGainedExperienceShower;
    }

    expToLevelUp() {
      return this.baseExpNextLevel() - this.currentExp;
    }

    baseExpNextLevel() {
      return this.expFor(this.currentLevel() + 1);
    }

    expFor(level) {
      const ax2 = Formula.QUADRATIC_COEFFICIENT * Math.pow(level, 2);
      const bx = Formula.LINEAR_COEFFICIENT * level;
      const c = Formula.CONSTANT_TERM;

      return ax2 + bx + c;
    }

    currentLevel() {
      return this.levelFor(this.currentExp);
    }

    levelFor(exp) {
      const a = Formula.QUADRATIC_COEFFICIENT;
      const b = Formula.LINEAR_COEFFICIENT;
      const c = Formula.CONSTANT_TERM;

      return Math.floor((-b + Math.sqrt(Math.pow(b, 2) - 4 * a * (c - exp))) / (2 * a));
    }

    triggersLevelChange(newExp) {
      return this.levelFor(this.currentExp + newExp) !== this.currentLevel();
    }

    currentLevelProgress() {
      return (this.currentExp - this.baseExpCurrentLevel()) / (this.baseExpNextLevel() - this.baseExpCurrentLevel());
    }

    baseExpCurrentLevel() {
      return this.expFor(this.currentLevel());
    }

    exercisesToNextLevel() {
      return Math.ceil(this.expToLevelUp() / 100);
    }

    setExpMessage(data) {
      const exp = data.current_exp;
      this.lastEarnedExp = exp - this.currentExp;

      if (this.lastEarnedExp > 0) {
        this.showLevelUpModalIfLevelUp(data.level_up_html);
        this._gainedExperienceShower();

        this.currentExp = exp;
        this.updateLevel();
      }
    }

    defaultGainedExperienceShower() {
      $('#mu-exp-points').html(this.lastEarnedExp);
      $('#mu-exp-earned-message').removeClass('hidden');
    }

    defaultLevelUpShower(_levelUpHtml) {
      $('#mu-level-up').modal();
    }

    registerLevelUpShower(shower) {
      this._levelUpShower = shower;
    }

    registerGainedExperienceShower(shower) {
      this._gainedExperienceShower = shower;
    }

    showLevelUpModalIfLevelUp(levelUpHtml) {
      if (this.triggersLevelChange(this.lastEarnedExp)) {
        this._levelUpShower(levelUpHtml);
      }
    }

    animateExperienceCounter(selector) {
      mumuki.animateNumberCounter(selector, this.lastEarnedExp);
    }

    updateLevel() {
      const $muLevelProgress = $('#mu-level-progress');

      $('#mu-solve-more-exercises span').text(this.exercisesToNextLevel());
      $('.mu-level-number').html(this.currentLevel());
      $('.mu-level-tooltip').attr("title", (_, value) => `${value} ${this.currentLevel()}`);

      if (this.currentLevelProgress() === 0) {
        $muLevelProgress.attr("display", "none");
      }

      $muLevelProgress.animate(
        {'progress': this.currentLevelProgress() * 250},
        {
          step: function(progress) {
            let pattern = progress + ", 999";
            $(this).attr("stroke-dasharray", pattern);
          },
          duration: 1000
        });
    }
  }

  function _setUpCurrentLevelProgression() {
    mumuki.gamification.currentLevelProgression = new LevelProgression(currentExp());
  }

  function currentExp() {
    return parseInt($('#mu-current-exp').val());
  }

  return {
    Formula,
    LevelProgression,

    _setUpCurrentLevelProgression,

    /** @type {LevelProgression} */
    currentLevelProgression: null
  };
})();

mumuki.load(() => {
  mumuki.gamification._setUpCurrentLevelProgression();
  mumuki.gamification.currentLevelProgression.updateLevel();
});
