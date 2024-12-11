package dn.phys;

/**
	A generic X/Y velocity utility class
**/
class Velocity {
	/** Custom identifier **/
	public var id = -1;

	public var x : Float;
	public var y : Float;
	public var z : Float;
	public var frictX : Float;
	public var frictY : Float;
	public var frictZ : Float;

	/** `v` is a convenience alias for `x` when you just need a 1D velocity **/
	public var v(get,set) : Float;
		inline function get_v() return x;
		inline function set_v(v:Float) return setAll(v);

	/** `x` alias **/
	public var dx(get,set) : Float;
		inline function set_dx(v) return x = v;
		inline function get_dx() return x;

	/** `y` alias **/
	public var dy(get,set) : Float;
		inline function set_dy(v) return y = v;
		inline function get_dy() return y;

	/** `z` alias **/
	public var dz(get,set) : Float;
		inline function set_dz(v) return z = v;
		inline function get_dz() return z;

	/** If absolute `x` or `y` goes below this value, instead, it is set to zero during next update. **/
	public var clearThreshold = 0.0005;

	public var frict(never,set) : Float;
		inline function set_frict(v) return frictX = frictY = frictZ = v;

	/** Angle in radians of the vector represented by x/y **/
	public var ang(get,never) : Float; inline function get_ang() return Math.atan2(y,x);

	/** Length of the vector represented by x/y **/
	public var hlen(get,never) : Float; inline function get_hlen() return Math.sqrt(x*x + y*y);

	/** Length of the vector represented by x/y **/
	public var len(get,never) : Float; inline function get_len() return Math.sqrt(x*x + y*y + z*z);

	/** Sign of X (-1 or 1) **/
	public var dirX(get,never) : Int; inline function get_dirX() return M.sign(x);

	/** Sign of Y (-1 or 1) **/
	public var dirY(get,never) : Int; inline function get_dirY() return M.sign(y);

	/** Sign of Z (-1 or 1) **/
	public var dirZ(get,never) : Int; inline function get_dirZ() return M.sign(z);


	public inline function new() {
		x = y = z = 0;
		frict = 1;
	}

	/** Create a Velocity instance with X and Y values **/
	public static inline function createXY(x:Float, y:Float, frict=1.) {
		var v = new Velocity();
		v.set(x,y,0);
		v.frict = frict;
		return v;
	}

	/** Create a Velocity instance with an angle and a length **/
	public static inline function createAng(ang:Float, len:Float, frict=1.) {
		var v = new Velocity();
		v.setAng(ang,len);
		v.frict = frict;
		return v;
	}

	/** Create a Velocity instance with just an initial friction **/
	public static inline function createFrict(frict:Float) {
		var v = new Velocity();
		v.frict = frict;
		return v;
	}

	@:keep public function toString() {
		return 'Velocity${ id<0?"":"#"+id }(${ shortString() })';
	}

	public inline function shortString() {
		return '${ M.pretty(x,2) },${ M.pretty(y,2) },${ M.pretty(z,2)}';
	}

	/** Set individual frictions **/
	public inline function setFricts(fx:Float, fy:Float, fz:Float = 1.0) {
		frictX = fx;
		frictY = fy;
		frictZ = fz;
	}

	/* Multiply X/Y values by individual factors */
	public inline function mulXY(fx:Float, fy:Float) {
		x*=fx;
		y*=fy;
	}

	/** Multiply both X/Y values by a factor **/
	public inline function mul(f:Float) {
		x*=f;
		y*=f;
		z*=f;
	}

	public inline function clear() {
		x = y = 0;
	}

	/** Add individual values to X/Y **/
	public inline function addXY(vx:Float, vy:Float) {
		x += vx;
		y += vy;
	}

	public inline function addLen(v:Float) {
		var l = len;
		var a = ang;
		x = Math.cos(a)*(l+v);
		y = Math.sin(a)*(l+v);
	}

	/** Set X and Y to specific values **/
	public inline function set(x:Float, y:Float, z:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	/** Set both X and Y to the same value **/
	public inline function setAll(v:Float) {
		return x = y = z = v;
	}

	/** Add a vector to this one **/
	public inline function addAng(ang:Float, v:Float) {
		x += Math.cos(ang)*v;
		y += Math.sin(ang)*v;
	}

	/** Set X and Y to specific values based on given angle and current length **/
	public inline function setAng(ang:Float, v:Float) {
		x = Math.cos(ang)*v;
		y = Math.sin(ang)*v;
	}

	public inline function rotate(angInc:Float) {
		var oldAng = ang;
		var d = len;
		dx = Math.cos(oldAng+angInc) * d;
		dy = Math.sin(oldAng+angInc) * d;
	}


	/** Return true if X and Y are both below the `clearThreshold` value **/
	public inline function isZero() return M.fabs(x)<=clearThreshold  &&  M.fabs(y)<=clearThreshold &&  M.fabs(z)<=clearThreshold;

	/** Call this method to update Velocity at fixed/constant FPS **/
	public inline function fixedUpdate(frictOverride=-1.) {
		frameUpdate(1, frictOverride);
	}

	/** Call this method to update Velocity at variable FPS **/
	public inline function frameUpdate(tmod:Float, frictOverride=-1.) {
		if( frictOverride>=0 ) {
			x *= Math.pow(frictOverride,tmod);
			y *= Math.pow(frictOverride,tmod);
			z *= Math.pow(frictOverride,tmod);
		}
		else {
			x *= Math.pow(frictX,tmod);
			y *= Math.pow(frictY,tmod);
			z *= Math.pow(frictZ,tmod);
		}

		if( M.fabs(x)<clearThreshold )
			x = 0;

		if( M.fabs(y)<clearThreshold )
			y = 0;

		if ( M.fabs(z)<clearThreshold )
			z = 0;
	}


	#if deepnightLibsTests
	public static function test() {
		// Init
		var v = new Velocity();
		CiAssert.equals( v.x, 0 );
		CiAssert.equals( v.y, 0 );
		CiAssert.equals( v.z, 0 );
		CiAssert.equals( v.isZero(), true );
		CiAssert.equals( v.shortString(), "0,0,0" );

		v.set(8,2,3);
		CiAssert.equals( v.x, 8 );
		CiAssert.equals( v.y, 2 );
		CiAssert.equals( v.z, 3 );
		CiAssert.equals( v.shortString(), "8,2,3" );
		CiAssert.equals( v.isZero(), false );

		// Frictions
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "8,2,3" );

		v.setFricts(0.5, 0.5, 0.5);
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "4,1,1.5" );
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "2,0.5,0.75" );

		// Threshold
		v.clearThreshold = 1;
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "1,0,0" );

		// Different frictions
		var v = new Velocity();
		v.set(8,2,3);
		v.setFricts(0.25, 0.5, 1);
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "2,1,3" );
		v.fixedUpdate();
		CiAssert.equals( v.shortString(), "0.5,0.5,3" );


		// Multiply
		v.set(8,2,3);
		v.mul(2);
		CiAssert.equals( v.shortString(), "16,4,6" );

		v.mulXY(2,3);
		CiAssert.equals( v.shortString(), "32,12,6" );

		v.mul(0);
		CiAssert.equals( v.shortString(), "0,0,0" );
		CiAssert.equals( v.isZero(), true );

		// Addition
		v.set(1,1,1);
		v.addXY(1,1);
		CiAssert.equals( v.shortString(), "2,2,1" );

		v.addXY(1,2);
		CiAssert.equals( v.shortString(), "3,4,1" );

		// Single value velocity
		var v = new Velocity();
		v.frict = 0.5;
		v.v = 4;
		CiAssert.equals( v.v, 4 );
		v.fixedUpdate();
		CiAssert.equals( v.v, 2 );
		v.fixedUpdate();
		CiAssert.equals( v.v, 1 );

		// Frame updates
		var v = new Velocity();
		v.frict = 0.5;
		v.v = 4;
		CiAssert.equals( v.v, 4 );
		v.frameUpdate(2);
		CiAssert.equals( v.v, 1 );
		v.frameUpdate(1);
		CiAssert.equals( v.v, 0.5 );
	}
	#end
}



/**
	Array of Velocity instances, with extra helper methods.
**/
class VelocityArray {
	var all : dn.struct.FixedArray<Velocity>;
	var _sum = 0.;

	public inline function new(maxLength:Int) {
		all = new dn.struct.FixedArray(maxLength);
	}

	@:keep public function toString() {
		return all.toString();
	}

	public inline function push(v:Velocity) {
		all.push(v);
	}

	public inline function remove(v:Velocity) : Bool {
		return all.remove(v);
	}

	public inline function empty() {
		all.empty();
	}

	public function dispose() {
		all.dispose();
		all = null;
	}

	/** Get the sum of all X values **/
	public inline function getSumX() {
		_sum = 0.;
		for(v in all)
			_sum+=v.x;
		return _sum;
	}

	/** Get the sum of all Y values **/
	public inline function getSumY() {
		_sum = 0.;
		for(v in all)
			_sum+=v.y;
		return _sum;
	}

	/** Get the sum of all Z values **/
	public inline function getSumZ() {
		_sum = 0.;
		for(v in all)
			_sum+=v.z;
		return _sum;
	}

	/** Get the overall "total" length of all vectors **/
	public inline function getOverallLen() {
		return Math.sqrt( getSumX()*getSumX() + getSumY()*getSumY() + getSumZ()*getSumZ() );
	}

	public inline function mulAll(f:Float) {
		for(v in all)
			v.mul(f);
	}

	public inline function mulAllX(f:Float) {
		for(v in all)
			v.mulXY(f,1);
	}

	public inline function mulAllY(f:Float) {
		for(v in all)
			v.mulXY(1,f);
	}

	public inline function mullAllZ(f:Float) {
		for(v in all)
			v.z *= f;
	}

	public inline function clearAll() {
		for(v in all)
			v.clear();
	}

	/** Remove "zero" velocities from array **/
	public function removeZeros() {
		var i = 0;
		while( i<all.allocated ) {
			if( all.get(i).isZero() )
				all.removeIndex(i);
			else
				i++;
		}
	}

	public inline function iterator() {
		return all.iterator();
	}
}
