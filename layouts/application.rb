file 'app/views/layouts/application.html.erb', <<-CODE
<!doctype html>
<html lang="en" class="no-js">
<head>
  <meta charset="utf-8">

  <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
  <meta name="description" content="">
  <meta name="author" content="">
  <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;">
  
  <link rel="shortcut icon" href="/favicon.ico">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
  
  <%= stylesheet_link_tag 'screen', 'print' %>
  <%= javascript_include_tag :defaults %>
  <%= csrf_meta_tag %>
  
  
  <script src="/javascripts/modernizr.js"></script>

  <title><%= head_title('Page Title') %></title>

</head>
<!--[if lt IE 7 ]> <body class="ie6 <%= body_classes %>"> <![endif]-->
<!--[if IE 7 ]>    <body class="ie7 <%= body_classes %>"> <![endif]-->
<!--[if IE 8 ]>    <body class="ie8 <%= body_classes %>"> <![endif]-->
<!--[if IE 9 ]>    <body class="ie9 <%= body_classes %>"> <![endif]-->
<!--[if (gt IE 9)|!(IE)]><!--> <body class="<%= body_classes %>"> <!--<![endif]-->
    
    <div id='container'>
      <%= yield %>
    </div>
    
    <%= render :partial => 'layout_partials/include_javascripts' %>
  </body>
</html>
CODE
