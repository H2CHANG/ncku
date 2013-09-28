var COOKIE_PATH = '/';


// run when page has fully loaded
$(document).ready(function() {

  // prevent vertical scrollbar from disappearing when all segments minimized
  $(document).find('body.js').css('overflow-y','scroll');

  // define hide/show segment behaviour
  $(document).find('.hideable').each(function() {

          // find out what segment this is
          var id = $(this).find('.hide-head').attr('id');

          // init hide/show link
          $(this).find('.hide-head').prepend('<a href="#" class="toggle show">[+]</a><a href="#" class="toggle hide">[&ndash;]</a> ');
          $(this).find('.show').hide();

          // eventually hide some segment bodies on init
          if($(this).find('.hide-body').hasClass('hidden')) {
              $(this).find('.toggle').toggle(0);
              $(this).find('.hide-body').hide();
          }

          // init state from cookies
          if($.cookie('hideable-show-'+id) == 'true') {
              $(this).find('.show').hide();
              $(this).find('.hide').show();
              $(this).find('.hide-body').show();
          }
          else if($.cookie('hideable-hide-'+id) == 'true') {
              $(this).find('.show').show();
              $(this).find('.hide').hide();
              $(this).find('.hide-body').hide();
          }
          else if($.cookie('hideable-showall') == 'true') {
              $(this).find('.show').hide();
              $(this).find('.hide').show();
              $(this).find('.hide-body').show();
          }
          else if($.cookie('hideable-hideall') == 'true') {
              $(this).find('.show').show();
              $(this).find('.hide').hide();
              $(this).find('.hide-body').hide();
          }

          // show segment body on click
          $(this).find('.show').click(function() {
                  $(this).parent().find('.show').hide(0);
                  $(this).parent().find('.hide').show(0);
                  $(this).parent().parent().find('.hide-body').show('slow');

                  // manage cookies
                  $.removeCookie('hideable-hide-'+id,{path:COOKIE_PATH});
                  $.cookie('hideable-show-'+id,true,{path:COOKIE_PATH});

                  // do not follow href link
                  return false;
              });

          // hide segment body on click
          $(this).find('.hide').click(function() {
                  $(this).parent().find('.show').show(0);
                  $(this).parent().find('.hide').hide(0);
                  $(this).parent().parent().find('.hide-body').hide('slow');

                  // manage cookies
                  $.removeCookie('hideable-show-'+id,{path:COOKIE_PATH});
                  $.cookie('hideable-hide-'+id,true,{path:COOKIE_PATH});

                  // do not follow href link
                  return false;
              });

      });

  // define hide-all-segments/show-all-segments behaviour
  $(document).find('.headline').each(function() {

          // init hide-all/show-all link
          $(this).prepend('<ul class="hide-control"><li title="expand all"><a href="#" class="show-all"><span class="generic-thin-icon">[+]</span></a></li><li title="collapse all"><a href="#" class="hide-all"><span class="generic-thin-icon">[&ndash;]</span></a></li></ul>');

          // show all segment bodies
          $(this).find('.show-all').click(function() {
                  $(document).find('.hide-head').find('.show').hide();
                  $(document).find('.hide-head').find('.hide').show();
                  $(document).find('.hide-body').show(1000);

                  // manage cookies
                  cookieList = document.cookie.split(';');
                  for( var i=0; i < cookieList.length; i++) {
                      var cookieName = jQuery.trim(cookieList[i]).split('=')[0];
                      if((/^hideable-/).test(cookieName)) {
                          $.removeCookie(cookieName,{path:COOKIE_PATH});
                      }
                  }
                  $.cookie('hideable-showall',true,{path:COOKIE_PATH});

                  // do not follow href link
                  return false;
              });

          // hide all segment bodies
          $(this).find('.hide-all').click(function() {
                  $(document).find('.hide-head').find('.show').show();
                  $(document).find('.hide-head').find('.hide').hide();
                  $(document).find('.hide-body').hide(1000);

                  // manage cookies
                  cookieList = document.cookie.split(';');
                  for( var i=0; i < cookieList.length; i++) {
                      var cookieName = jQuery.trim(cookieList[i]).split('=')[0];
                      if((/^hideable-/).test(cookieName)) {
                          $.removeCookie(cookieName,{path:COOKIE_PATH});
                      }
                  }
                  $.cookie('hideable-hideall',true,{path:COOKIE_PATH});

                  // do not follow href link
                  return false;
              });
      });

  // always show segment when using inpage navigation
  $(document).find('.side').find('a').click(function() {

          // find out what segment this is
          var target = $(this).attr('href');

          // dont care for top or bottom inpage nav
          if( target != '#' && target != '#footer' ) {

              // show segment
              $(document).find(target).find('.show').hide(0);
              $(document).find(target).find('.hide').show(0);
              $(document).find(target).parent().find('.hide-body').show('slow');

              // manage cookies
              var id = $(document).find(target).attr('id');
              $.removeCookie('hideable-hide-'+id,{path:COOKIE_PATH});
              $.cookie('hideable-show-'+id,true,{path:COOKIE_PATH});

          }
          // do follow href link
          return true;
      });


  // init filter checkboxes and view state from ccokies
  $(document).find('.filter').find('.type-filter').each(function() {

          // find out what type this is
          var id = $(this).attr('name');

          // init state from cookies
          if($.cookie('filter-show-'+id) == 'false') {
              $(document).find('.publ-list .'+id).hide('fast');
              $(document).find('.publ-list li.'+id).css('display','none'); // FIXME: hot-fix
              $(this).attr('checked', false);
          }
          else {
              $(this).attr('checked', true);
          }

          // redefine drop-down box label as appropriate
          var showall = true;
          $(document).find('.filter').find('.type-filter').each(function() {
                  if( ! $(this).is(":checked") ) { showall = false; }
              });
          if( showall == true ) {
              $(document).find('.filter').find('.head').text('-- show all --');
          }
          else {
              $(document).find('.filter').find('.head').text('-- custom ---');
          }

      });

  // disable inactive coauthor index back-links on init
  /* FIXME: quite slow on large pages, eventually uncomment the following block
  $(document).find('.index>div>div:last-child>a').each(function() {

          // find out what nr this is
          var nr = $(this).text();
          nr = nr.substring(1,nr.length-1);

          // handle unused links
          if( $('#'+nr).parent().css('display') == 'none' ) {
              $(this).hide(0);
          }
      });
  */

  // define filter checkbox click behaviour
  $(document).find('.filter').find('.type-filter').click(function() {

          // find out what type this is
          var id = $(this).attr('name');

          // init state from cookies
          if( $(this).is(":checked") ) {
              $(document).find('.publ-list li.'+id).show('fast');
              $(document).find('.publ-list li.'+id).css('display','table'); // FIXME: hot-fix
              $.cookie('filter-show-'+id,true,{path:COOKIE_PATH});
          }
          else {
              $(document).find('.publ-list li.'+id).hide('fast');
              $(document).find('.publ-list li.'+id).css('display','none'); // FIXME: hot-fix
              $.cookie('filter-show-'+id,false,{path:COOKIE_PATH});
          }

          // redefine drop-down box label as appropriate
          var showall = true;
          $(document).find('.filter').find('.type-filter').each(function() {
                  if( ! $(this).is(":checked") ) { showall = false; }
              });
          if( showall == true ) {
              $(document).find('.filter').find('.head').text('-- show all --');
          }
          else {
              $(document).find('.filter').find('.head').text('-- custom ---');
          }

          // disable/enable coauthor index back-links
          /* FIXME: quite slow on large pages, eventually uncomment the following block
          $(document).find('.index>div>div:last-child>a').each(function() {

                  // find out what nr this is
                  var nr = $(this).text();
                  nr = nr.substring(1,nr.length-1);

                  // handle unused links
                  if( $('#'+nr).parent().css('display') == 'none' ) {
                      $(this).hide(0);
                  }
                  else {
                      $(this).show(0);
                  }
              });
          */

      });


  // auto-copy to clipboard
  //$(document).find('.autocopy').each( function() {
  //        alert($(this).text());
  //    });
  //$(document).find('.autocopy').zclip({
  //
  //        path: "../js/ZeroClipboard.swf",
  //        copy: function() {
  //            return $(this).text();
  //        }
  //    });

});
