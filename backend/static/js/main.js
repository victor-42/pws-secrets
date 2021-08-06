/*-----------------------------------------------------------------------------------
/*
/* Main JS
/*
-----------------------------------------------------------------------------------*/

(function($) {

   /*----------------------------------------------------*/
   /* Preloader
   ------------------------------------------------------*/
   $(window).load(function() {

      // will first fade out the loading animation
      $("#loader").fadeOut("slow", function(){

        // will fade out the whole DIV that covers the website.
        $("#preloader").delay(200).fadeOut("slow");

      });

    })

   /*-----------------------------------------------------*/
   /* Modals
   -------------------------------------------------------*/
   $('.modal-toggles ul').on('click', 'a', function(e) {

   	var html = $('html'),
   		 main = $('main, footer'),
   		 footer = $('footer'),
          curMod = $(this).attr('href'),
          modal = $(curMod),
          modClose = modal.find('#modal-close');

		main.fadeOut(500, function(){
			$('html,body').scrollTop(0);
        	modal.addClass('is-visible');
      });

      e.preventDefault();

      // for old ie
      if (html.hasClass('oldie')) {

      	$(document).on('click', "#modal-close", function(evt) {
	      	$('html,body').scrollTop(0);
	      	modal.removeClass('is-visible');
	      	setTimeout(function() {
	        		main.fadeIn(500);
	        	}, 500);

	        	evt.preventDefault();
      	});

      }
      // other browsers
      else {

      	modClose.on('click', function(evt) {
	      	$('html,body').scrollTop(0);
	      	modal.removeClass('is-visible');
	      	setTimeout(function() {
	        		main.fadeIn(500);
	        	}, 500);

	        	evt.preventDefault();
	      });

      }

   });

	$('.password-generate').on('click', function (e) {
		var length = 10,
			charset = "abcdefghijkl+*%mnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789",
			retVal = "";
		for (var i = 0, n = charset.length; i < length; ++i) {
			retVal += charset.charAt(Math.floor(Math.random() * n));
		}
		$('#id_password').val(retVal)
	});

	$('#secret-mode-toggle').on('click', function (e) {
		if ($('#addPassword').hasClass('show')) {
			$('#toggle-icon').attr('class', 'fas fa-key')
		} else if ($('#addStickyNote').hasClass('show')) {
			$('#toggle-icon').attr('class', 'far fa-sticky-note')
		}
	})

})(jQuery);
