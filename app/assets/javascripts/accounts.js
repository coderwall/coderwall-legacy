$(function() {
  var publishableKey = $('meta[name="stripe-key"]').attr('content');
  $(document).on("click", ".selectPlan", function() {
    var form = $($(this).attr('data-form'));
    var token = function(res) {
      var input = form.find('.x_stripe_card_token_value').val(res.id);
      console.log(res.id);
      return form.submit();
    };

    StripeCheckout.open({
      key: publishableKey,
      amount: $(this).attr('data-price'),
      currency: "usd",
      name: $(this).attr('data-plan-name'),
      description: $(this).attr('data-plan-desc'),
      panelLabel: 'Subscribe',
      token: token
    });

    return false;
  });
});

