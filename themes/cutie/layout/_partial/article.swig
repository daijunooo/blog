<style>
    body {
        background-color: white;
    }
</style>

<article class="article" id="{{ url_for(item.path) }}" data-name='{{ item.title }}' data-version="{{ item.version }}">

    <!-- Title -->

    {% if item.categories && item.categories.length %}
        {% for cat in item.categories %}
            {% if loop.first %}
                {% set category_name = cat.name %}
                {% set category_link = url_for(cat.path) %}
            {% endif %}
        {% endfor %}
    {% else %}
        {% set category_link = url_for(item.path) %}
        {% set category_name = 'uncategorized' %}
    {% endif %}

    <div class='article-header'>
         {% if item.icon %}
         <div class='article-logo'>
            <a href="#" data-no-instant>
                <img src="{{ item.icon }}" alt="">
            </a>
         </div>
         {% endif %}
         <h1 class='article-title'>
            <a href="{{ url_for(item.path) }}">
                {{ titlecase(item.title) | default("No title") }}
            </a>
        </h1>
        {% if item.categories && item.categories.length %}
        <ul class='article-categories'>
            {% for cat in item.categories %}
            {% set category_link = url_for(cat.path) %}
                <li><a href="{{ category_link }}" data-no-instant>
                    <img src="{{ '/images/' + cat.name + '.svg' }}" alt="{{ cat.name }}" />
                </a></li>
            {% endfor %}
        </ul>
        {% endif %}
    </div>
   
    <!-- Date and Author -->
    <p>
       	{{ item.date.format(config.date_format) }}
        by {{ item.author | default(config.author) }}
        {% if item.version and item.version != -1 %}
            | Version: {{ item.version }}
        {% endif %}
    </p>
    <p>
        {{ partial("_partial/article-tags", {item: item}) }}
    </p>
	<hr />

    <!-- Gallery -->
    {% if item.photos && item.photos.length %}
        <div class='article-gallery' id='lightgallery'>
            {% for photo in item.photos %}
                <a class='article-gallery-item' href="{{ '/images/' + String(item.path).split('/')[3] + '/' + photo }}" data-no-instant>
                    <img src="{{ '/images/' + String(item.path).split('/')[3] + '/' + photo }}" alt="" />
                </a>
            {% endfor %} 
        </div>
        <hr>
    {% endif %}
    

    <!-- Content -->
    <div class='article-content'>
    {{ item.content | default("No content") }}
    </div>
    <hr />

    <h2>Share and comment</h2>
    <div class="social-share"></div>
    <br />
    {% if comment %}
        <div id="comment"></div>
        <script src="//cdn1.lncld.net/static/js/3.0.4/av-min.js"></script>
        <script src='//unpkg.com/valine@1.3.6/dist/Valine.min.js'></script>
        <script>
        new Valine({
            el: '#comment' ,
            notify: false,
            verify: false,
            appId: 'Qkxf6mGlzXxuoNkKXnaLqtfQ-gzGzoHsz',
            appKey: '1epaom2Ta3x0GWm0yGC2p1o6',
            placeholder: '你想说点什么...',
            path: window.location.pathname,
            avatar: 'retro'
        });
        </script>
    {% endif %}

    
    
</article>