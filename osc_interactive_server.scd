(
//n = NetAddr("127.0.0.1"); // local machine
var features = [[Chromagram]];
var ventaneo = 1;
t = ~startRec.("~/Desktop/recs", 1, {|fileName|
	Task({
		0.1.wait;
		~res = ~getAudioFeatures.([[fileName]], nil, features, ~ventanizar, ventaneo);
		~data = ~res[\unknown].flatten.flatten;
		~client.sendMsg("/wek/inputs", *~data); //default out port 5005
	}).play
});
~client = NetAddr("127.0.0.1", 5006); // loopback ----
)


(
OSCdef (\osc_out, {|msg, time, addr, recvPort|
	var clase, ocarina, caracol, glisandi, fondo, guitarra, voz;
	# clase, ocarina, caracol, glisandi, fondo, guitarra, voz = msg;

	ocarina.abs;
	caracol.abs;
	glisandi.abs;
	fondo.abs;
	guitarra.abs;
	voz.abs;

	if ((ocarina > 0.6),{
		"Esta sonando la Ocarinaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".postln;

		Ndef(\sinte, {
			var sig, env;
			sig = PlayBuf.ar(2, ~complejo[0..~complejo.size].choose,(-7..0).choose.midiratio, 1, doneAction: 2);
			env = EnvGen.kr(Env.new([0,0.8,0.8,0], [2, 7, 2]));
			sig = sig * env;
		}
		)
	});

	if ((caracol > 0.6),{
		"Esta sonando el Caracolllllllllllllllllllllllllllllllll".postln;
		Ndef (\sinte, {
			Mix.new(Pan2.ar(SinOsc.ar([
				ocarina.linexp(0,1, 1, 222, 6002), //mapeo de datos //sonificación
				caracol.linexp(0,1, 1, 309, 1009),
				glisandi.linexp(0,1, 1, 305, 380),
				fondo.linexp(0,1, 1, 513, 6000),
			], 0, 0.4), fondo.linexp(0, 1, -0.5, 0.5), 0.5));
		})
	});

	if ((glisandi > 0.6),{
		"Esta sonando el Glisandiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii".postln;

		Ndef(\sinte, {
			var in, freq, hasfreq, sin;
			in = SoundIn.ar(0, 1);
			#freq, hasfreq = Tartini.kr(in, 0.13);
			sin = SinOsc.ar(freq.lag(10), 0, 0.08);
		}).play
	});

	if ((fondo > 0.6),{
		Synth(\fijo, [\buf, ~fijo[1..~fijo.size].choose, \rate, (-8..2).choose.midiratio])
	});

	if ((guitarra > 0.6),{
		"Esta escuchando guitarraaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa".postln;

		Synth(\periodico, [\buf, ~periodico[1..~periodico.size].choose, \rate, (-8..2).choose.midiratio])

	});

	if ((voz > 0.6),{

				"Esta escuchando vozzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz".postln;

				Synth(\fijo, [\buf, ~fijo[1..~fijo.size].choose, \rate, (-8..2).choose.midiratio])
	});

},"/wek/outputs", recvPort: 5007);
)

Ndef(\sinte).play
Ndef(\sinte).fadeTime=2

(
OSCdef (\osc_out, {|msg, time, addr, recvPort|
	var clase, ocarina, caracol, glisandi, fondo;
	# clase, ocarina, caracol, glisandi, fondo= msg;

	ocarina;

	Task({
		ocarina.postln;
		caracol.postln;
		glisandi.postln;
		fondo.postln;
	}).play;

},"/wek/outputs", recvPort: 5007);
)
