<head>

  <!-- Basic Page Needs
  –––––––––––––––––––––––––––––––––––––––––––––––––– -->
  <meta charset="utf-8">
  {% if is_home() %}
      <title>{{ config.title }}</title>
  {% endif %}
  {% if is_year() %}
      <title>{{ page.year + " - Archive - " + config.title }}</title>
  {% endif %}
  {% if is_archive() %}
      <title>{{ "Archive - " + config.title }}</title>
  {% endif %}
  {% if is_category() %}
      <title>{{ page.category + " - Category - " + config.title }}</title>
  {% endif %}
    {% if is_tag() %}
      <title>{{ page.tag + " - Tag - " + config.title }}</title>
  {% endif %}
  {% if is_post() %}
      <title>{{ page.title | default('No title') + " - " + config.title }}</title>
  {% endif %}
  
  <meta name="description" content="">
  <meta name="author" content="">
  <link rel="shortcut icon" href="{{ url_for('images/favicon.ico') }}" />
  <link rel="bookmark"href="{{ url_for('images/favicon.ico') }}" />

  <!-- Mobile Specific Metas
  –––––––––––––––––––––––––––––––––––––––––––––––––– -->
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- CSS
  –––––––––––––––––––––––––––––––––––––––––––––––––– -->

 <!-- CSS
  {{ css(['css/normalize.css', 'css/font-awesome.min.css', 'css/gridlex.min.css', 'css/skeleton.css', 'css/theme.css', 'css/share.min.css', 'css/lightgallery.css']) }}
   –––––––––––––––––––––––––––––––––––––––––––––––––– -->

    <link href="https://cdn.bootcss.com/normalize/3.0.2/normalize.min.css" rel="stylesheet">
    <link href="https://cdn.bootcss.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet">
    <link href="https://cdn.bootcss.com/gridlex/2.3.7/gridlex.min.css" rel="stylesheet">
    {{ css(['css/skeleton.css', 'css/theme.css']) }}
    <link href="https://cdn.bootcss.com/social-share.js/1.0.11/css/share.min.css" rel="stylesheet">
    <link href="https://cdn.bootcss.com/lightgallery/1.6.8/css/lightgallery.min.css" rel="stylesheet">

  <script src="https://cdn.bootcss.com/js-cookie/2.2.0/js.cookie.min.js"></script>
  <script src="https://cdn.bootcss.com/social-share.js/1.0.11/js/social-share.min.js"></script>
    <!-- {{ js('js/social-share.min.js') }} -->
    {{ js('js/theme.js')}}

  <!-- include cookie.js -->
  
  {{ partial('_partial/google_analytics') }}

</head>