var checkArmor = false;
let health;
let armor;

let muerto = false;

(() => {
	OrigenHUD = {};

	OrigenHUD.CarHud = function (data) {
		if (data.show) {
			$('.ui-car-container').fadeIn();
			$('.hud-info')
				.removeClass('scale-up')
				.css('opacity', 100)
				.addClass('scale-down');
			setTimeout(() => {
				$('.hud-info').each(function (n) {
					if ($(this).css('display') != 'none') {
						$(this)
							.removeClass('scale-down')
							.css('opacity', 0)
							.addClass('scale-up');
					}
				});
			}, 1000);
		} else {
			$('.ui-car-container').fadeOut();
		}
	};

	OrigenHUD.UpdateHud = function (data) {
		if (!data.show) {
			$('.ui-container').fadeIn(300);
		} else {
			$('.ui-container').fadeOut(300);
		}

		if (typeof data.health === 'number' && data.health != health) {
			health = data.health;
			$('.barras .barra.vida .content-barra').animate(
				{ width: Math.max(0, Math.min(100, data.health)) + '%' },
				1000
			);
		}

		if (typeof data.armor === 'number' && data.armor != armor) {
			armor = data.armor;
			$('.barras .barra.chaleco').fadeIn(300);
			$('.barras .barra.chaleco .content-barra').animate(
				{ width: Math.max(0, Math.min(100, data.armor)) + '%' },
				1000
			);
		}

		var rango = 'Whisper';
		switch (data.voice) {
			case 1:
				rango = 'Whisper';

				cambiarRango(rango);
				break;
			case 2:
				rango = 'Normal';
				cambiarRango(rango);

				break;
			case 3:
				rango = 'Shout';
				cambiarRango(rango);

				break;
		}
		if (data.talking == 1) {
			$('.voz').addClass('hablando');
		} else {
			$('.voz').removeClass('hablando');
		}

		$('.fuel-text').html(data.fuel.toFixed(0) + 'L.');
		$('.ui-car-fuel').fadeIn(300);
		
		if (data.fuel.toFixed(0) < 20) {
			$('.ui-car-fuel').css('background-color', '#cf6f01cf');
			$('.fuel-text').css('color', 'white');
			$('.ui-car-fuel img').css('filter', 'invert(0)');
		} else {
			$('.ui-car-fuel').css('background-color', '#ffffffcf');
			$('.fuel-text').css('color', 'black');
			$('.ui-car-fuel img').css('filter', 'invert(1)');
		}
	};

	window.onload = function (e) {
		window.addEventListener('message', function (event) {
			switch (event.data.action) {
				case 'show':
					OrigenHUD.Show(event.data);
					break;
				case 'hudtick':
					OrigenHUD.UpdateHud(event.data);
					break;
				case 'speedtick':
					let speed = parseInt(event.data.speed * 1.60934);
					if (speed <= 2) {
						$('.ui-car-container').fadeOut(300);
					} else {
						$('.ui-car-container').fadeIn(300);
					}
					$('.speed-text').html(speed);
					break;
				case 'car':
					OrigenHUD.CarHud(event.data);
					break;

				case 'mostrar-muerte':
					mostrarMuerte(event.data.tiempo);
					break;
				case 'mostrar-respawn':
					muerto = true;
					mostrarRespawn(event.data.msg);
					break;
				case 'ocultar-muerte':
					muerto = false;
					$('.zona-muerte').fadeOut(300);
					$('.blood-overlay').css('opacity', '0');

					$('.zona-respawn').css('display', 'none');
					break;

				case 'showRadio':
					cambioVoz('Radio');
					break;
				case 'hideRadio':
					cambioVoz(rangoAnterior, true);

					break;
			}
		});
	};
})();

var rangoAnterior = '';
var timeVoz;
function cambiarRango(rango) {
	if (
		rango != rangoAnterior &&
		rangoAnterior != 'Radio' &&
		rangoAnterior != 'Escuchando'
	) {
		$('.bg-voz img').fadeOut(100);
		$('#' + rango).fadeIn(100);

		if ($('#texto-voz').css('display') == 'block') {
			$('#texto-voz')
				.addClass('slide-up-out')
				.fadeOut(150, function () {
					$(this)
						.text(rango)
						.removeClass('slide-up-out')
						.addClass('slide-down-in')
						.fadeIn(150, function () {
							$('.voz').css('opacity', '1');

							$(this).removeClass('slide-down-in');
							clearTimeout(timeVoz);
							timeVoz = setTimeout(function () {
								$('#texto-voz').fadeOut(200);
								$('.voz').css('opacity', '0');
							}, 2000);
						});
				});
		} else {
			$('.voz').css('opacity', '1');
			$('#texto-voz')
				.text(rango)
				.removeClass('slide-up-out')
				.addClass('slide-down-in')
				.fadeIn(150, function () {
					$(this).removeClass('slide-down-in');
					clearTimeout(timeVoz);
					timeVoz = setTimeout(function () {
						$('#texto-voz').fadeOut(150);
						$('.voz').css('opacity', '0');
					}, 2000);
				});
		}

		setTimeout(() => {}, 100);

		rangoAnterior = rango;
	}
}

function cambioVoz(rango, anim) {
	$('.bg-voz img').fadeOut(100);
	$('#' + rango).fadeIn(100);
	if ($('#texto-voz').css('display') == 'block' && rango != 'Escuchando') {
		$('#texto-voz')
			.addClass('slide-up-out')
			.fadeOut(200, function () {
				$(this)
					.text(rango)
					.removeClass('slide-up-out')
					.addClass('slide-down-in')
					.fadeIn(200, function () {
						$(this).removeClass('slide-down-in');
						clearTimeout(timeVoz);
						if (anim) {
							timeVoz = setTimeout(function () {
								$('#texto-voz').fadeOut(200);
							}, 2000);
						}
					});
			});
	} else {
		if (rango == 'Escuchando') {
			$('.voz').addClass('hablando');
		} else {
			$('.voz').removeClass('hablando');
			clearTimeout(timeVoz);
			$('#texto-voz').fadeOut(300);
		}
		$('#texto-voz')
			.text(rango)
			.removeClass('slide-up-out')
			.addClass('slide-down-in')
			.fadeIn(200, function () {
				$(this).removeClass('slide-down-in');
				clearTimeout(timeVoz);
			});
	}
}

function mostrarMuerte(tiempo) {
	$('.zona-tiempo').css('display', 'block');
	$('.titulo-muerte').html(
		'<i class="fas fa-skull-crossbones"></i> ¡Estás herido! <i class="fas fa-skull-crossbones"></i>'
	);
	$('.zona-respawn').css('display', 'none');
	$('.zona-muerte').css('display', 'block');
	$('.zona-muerte .tiempo').text(tiempo);
	$('.blood-overlay').css('opacity', '100');
}

function mostrarRespawn(msg) {
	$('.zona-muerte').css('display', 'block');
	$('.zona-tiempo').css('display', 'none');
	$('.zona-respawn').css('display', 'block');
	$('.titulo-muerte').html('Necesitas atención médica');
	$('.zona-respawn').html(msg);
	$('.blood-overlay').css('opacity', '100');
}
