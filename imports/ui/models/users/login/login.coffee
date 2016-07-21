require './login.jade'


class Login extends BlazeComponent
  @register 'Login'

  constructor: (args) ->

  onCreated: ->
    @state = new ReactiveDict
    @loginState()

  onRendered: ->
    @enterAnimation()


  onStateChange: (event) ->
    if @state.get 'log'
      @signupState()
    else
      @loginState()

  loginState: ->
    @state.set('log', true)
    @state.set('title', 'Login')
    @state.set('forgot', '1')
    @state.set('height', '0px')
    @state.set('form', 'js-login-form')
    @state.set('button', 'js-login-button')

  signupState: ->
    @state.set('log', false)
    @state.set('title', 'Sign Up')
    @state.set('forgot', '0')
    @state.set('height', '130px')
    @state.set('form', 'js-signup-form')
    @state.set('button', 'js-signup-button')


  stateInfo: ->
    @state.all()


  onLogin: (event) ->
    event.preventDefault()
    email = @find('[name=email]').value
    password = @find('[name=password]').value
    @login email, password

  onSignup: (event) ->
    event.preventDefault()
    email = @find('[name=email]').value
    password = @find('[name=password]').value
    profile =
      first_name: @find('[name=first_name]').value
      last_name: @find('[name=last_name]').value

    @signup email, password, profile

  login: (email, password) ->
    Meteor.loginWithPassword email, password, (err) =>
      console.log err
      unless err?
        Meteor.logoutOtherClients( (er) =>
          @exitAnimation() unless er?
        )

  signup: (email, password, profile) ->
    Accounts.createUser {email, password, profile}, (err) =>
      console.log err
      @exitAnimation() unless err?


  exitAnimation:  ->
    logindiv = $(@find('.login-div'))
    logindiv.velocity
      p:
        opacity: 0
      o:
        duration: 350
        easing: 'ease-in-out'
        complete: (elements) ->
          FlowRouter.go 'home'

  enterAnimation: ->
    logindiv = $(@find('.login-div'))
    logindiv.velocity
      p:
        opacity: 1
      o:
        duration: 350
        easing: 'ease-in-out'





  events: ->
    super.concat
      "click #js-state": @onStateChange
      "submit .js-signup-form": @onSignup
      "submit .js-login-form": @onLogin
      "click .js-login-button": @onLogin
      "click .js-signup-button": @onSignup
