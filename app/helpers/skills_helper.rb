module SkillsHelper
  HINTS = [
      'Receive 3 endorsements to unlock a skill.',
      'Create a protip tagged with this skill and unlock the skill when the protip is upvoted 5 times.',
      'Unlock a skill by creating open source projects with the language.',
      "Add the conferences you are attending on Lanyrd and link your twitter account."
  ]

  def skill_help_text(skill)
    if viewing_self?
      hint = unlock_hint
      "#{skill.name} is locked. <span class='hint'> #{hint ? "Hint:" + hint : nil}</span>".html_safe
    else
      skill.endorse_message
    end
  end

  def unlock_hint
    @unsed_hints = HINTS.dup if @unsed_hints.nil? #|| @unsed_hints.empty?
    hint = @unsed_hints.sample
    @unsed_hints.delete(hint)
    hint
  end

end