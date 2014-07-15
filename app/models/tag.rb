class Tag < ActiveRecord::Base
  acts_as_followable

  VALID_PROGRAMMING_LANGUAGES = %w(github slideshare python ruby javascript php objective-c java viml perl clojure coffeescript scala erlang emacslisp go haskell actionscript lua groovy git commonlisp puppet hackerdesk css assembly ocaml haxe scheme vim coldfusion d rails powershell objective-j bash ios html dart matlab jquery android arduino xcode osx html5 css3 visualbasic rubyonrails mysql delphi smalltalk mac iphone linux ipad mirah nodejs tcl apex wordpress cocoa nodejs heroku io js dcpu-16asm django zsh rspec programming vala sql mongodb workspace racket twitter terminal development opensource testing design emberjs security verilog net blurandpure mobile sass code webkit api json nginx elixir agile bundler emacs web drupal unix csharp photoshop nodejs facebook log reference cli sublimetext responsive tdd puredata asp codeigniter maven rubygems gem oracle nosql rvm ui branch responsivedesign fortran postgresql latex nimrod documentation rubymotion redis backbone ubuntu regex textmate fancy ssh performance spring sublimetext2 boo flex coq aliases browser webdevelopment rest eclipse tips factor commandline sublimetext ooc blog unittesting server history lion tip autohotkey alias prolog apple standardml vhdl objectivec statistics impactgameengine apache cucumber cpp meta gist dropbox gitignore rails3 debug flask cplusplus monitoring angularjs oauth oop usability flexmojos sentry expressionengine ee)

  scope :from_topic, lambda { |topic| where(name: topic) }

  def subscribe(user)
    user.follow(self)
  end

  def unsubscribe(user)
    user.stop_following(self)
  end
end

# == Schema Information
# Schema version: 20140713193201
#
# Table name: tags
#
#  id   :integer          not null, primary key
#  name :string(255)
#
