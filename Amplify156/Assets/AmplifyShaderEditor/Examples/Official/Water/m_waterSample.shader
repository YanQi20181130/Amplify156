// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "YQ/m_water"
{
	Properties
	{
		_deepcolor("deep color", Color) = (0,0,0,0)
		_shalowcolor("shalow color", Color) = (0,0,0,0)
		_normaltexture("normal texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _normaltexture;
		uniform float4 _normaltexture_ST;
		uniform float4 _deepcolor;
		uniform float4 _shalowcolor;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_normaltexture = i.uv_texcoord * _normaltexture_ST.xy + _normaltexture_ST.zw;
			o.Normal = tex2D( _normaltexture, uv_normaltexture ).rgb;
			float4 lerpResult1 = lerp( _deepcolor , _shalowcolor , 0.0);
			o.Albedo = lerpResult1.rgb;
			float lerpResult6 = lerp( _deepcolor.a , _shalowcolor.a , 0.0);
			o.Alpha = lerpResult6;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
0;445;1208;583;1077.468;717.8806;1.659316;True;True
Node;AmplifyShaderEditor.ColorNode;3;-498.9564,-276.3494;Float;False;Property;_shalowcolor;shalow color;1;0;Create;True;0;0;False;0;0,0,0,0;0.07843137,0.9921569,0.4380687,0.454902;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;2;-463.8553,-460.0927;Float;False;Property;_deepcolor;deep color;0;0;Create;True;0;0;False;0;0,0,0,0;0.02985938,0.04751687,0.5754717,0.7686275;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-126.3727,-705.5689;Float;True;Property;_normaltexture;normal texture;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-432.8947,-679.0823;Float;False;Property;_reflectioncolor;reflection color;3;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;6;5.047961,-64.39748;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;1;-76.89649,-317.6582;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;190.0846,-270.8981;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;YQ/m_water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Translucent;0.5;True;False;0;False;Opaque;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;6;0;2;4
WireConnection;6;1;3;4
WireConnection;1;0;2;0
WireConnection;1;1;3;0
WireConnection;0;0;1;0
WireConnection;0;1;4;0
WireConnection;0;9;6;0
ASEEND*/
//CHKSM=FDD0CE46188ADCC981B705E59AB69345AD7B62B0