<nav class="menu">
	{% if config.cutie.menu %}
		{% set menu = config.cutie.menu %}
	{% else %}
		{% set menu = theme.menu %}
	{% endif %}
	
	{% set count = false %}
	{% for menu_name, menu_content in menu %}
		{% if loop.index == 7 %}
			{% set count = true %}
		{% endif %}
		{% if not count %}
			<div class='menu-item grow'>
			{% if menu_content.icon %}
				<div class='menu-icon'>
				<a href="{{ menu_content.link }}">
					<img src="{{ menu_content.icon }}" alt="">
					</a>
					</div>
					{% endif %}
					<div class="menu-name">
						<a class='menu-link' href="{{ menu_content.link }}">
							<span>{{ menu_name | capitalize }}</span>
						</a>
					</div>
				</a>
			</div>
		{% endif %}
	{% endfor %}
</nav>
