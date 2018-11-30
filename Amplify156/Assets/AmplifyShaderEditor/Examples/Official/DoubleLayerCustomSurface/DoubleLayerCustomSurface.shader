// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ASESampleShaders/Double Layer Custom Surface"
{
	Properties
	{
		_BaseColor1("Base Color 1", Color) = (1,0.9310344,0,0)
		_BaseColor2("Base Color 2", Color) = (1,0.9310344,0,0)
		_BaseMetallic("Base Metallic", Range( 0 , 1)) = 0
		_BaseSmoothness("Base Smoothness", Range( 0 , 1)) = 0
		_BaseOcclusion("Base Occlusion", Range( 0 , 1)) = 0
		_FlakesRGBcolorvariationAmask("Flakes (RGB = color variation, A = mask)", 2D) = "white" {}
		_FlakeColorVariationAmount("Flake Color Variation Amount", Range( 0 , 1)) = 0
		_FlakesColor1("Flakes Color 1", Color) = (1,0.9310344,0,0)
		_FlakesColor2("Flakes Color 2", Color) = (1,0.9310344,0,0)
		_FlakesMetallic("Flakes Metallic", Range( 0 , 1)) = 0
		_FlakesSmoothness("Flakes Smoothness", Range( 0 , 1)) = 0
		_FlakesNormal("Flakes Normal", 2D) = "bump" {}
		_FlakesBump("Flakes Bump", Range( 0 , 1)) = 0
		_CoatNormal("Coat Normal", 2D) = "bump" {}
		_CoatBump("Coat Bump", Range( 0 , 1)) = 0
		_CoatAmount("Coat Amount", Range( 0 , 1)) = 0
		_CoatSmoothness("Coat Smoothness", Range( 0.05 , 1)) = 0
		_power("power", Float) = 0
		_scale("scale", Range( 0 , 1)) = 0
		_Specintensity("Spec intensity", Float) = 1
		_bias("bias", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityStandardUtils.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform float4 _BaseColor1;
		uniform float4 _BaseColor2;
		uniform float _bias;
		uniform float _scale;
		uniform float _power;
		uniform float4 _FlakesColor1;
		uniform float4 _FlakesColor2;
		uniform sampler2D _FlakesRGBcolorvariationAmask;
		uniform float4 _FlakesRGBcolorvariationAmask_ST;
		uniform float _FlakeColorVariationAmount;
		uniform float _FlakesBump;
		uniform sampler2D _FlakesNormal;
		uniform float _BaseMetallic;
		uniform float _FlakesMetallic;
		uniform float _BaseSmoothness;
		uniform float _FlakesSmoothness;
		uniform float _BaseOcclusion;
		uniform float _CoatBump;
		uniform sampler2D _CoatNormal;
		uniform float4 _CoatNormal_ST;
		uniform float _Specintensity;
		uniform float _CoatSmoothness;
		uniform float _CoatAmount;

		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			SurfaceOutputStandard s1 = (SurfaceOutputStandard ) 0;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV201 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode201 = ( _bias + _scale * pow( 1.0 - fresnelNdotV201, _power ) );
			float4 lerpResult278 = lerp( _BaseColor1 , _BaseColor2 , fresnelNode201);
			float4 lerpResult277 = lerp( _FlakesColor1 , _FlakesColor2 , fresnelNode201);
			float2 uv_FlakesRGBcolorvariationAmask = i.uv_texcoord * _FlakesRGBcolorvariationAmask_ST.xy + _FlakesRGBcolorvariationAmask_ST.zw;
			float4 tex2DNode228 = tex2D( _FlakesRGBcolorvariationAmask, uv_FlakesRGBcolorvariationAmask );
			float4 lerpResult227 = lerp( lerpResult277 , tex2DNode228 , _FlakeColorVariationAmount);
			float FlakeMask284 = tex2DNode228.a;
			float4 lerpResult217 = lerp( lerpResult278 , lerpResult227 , FlakeMask284);
			s1.Albedo = lerpResult217.rgb;
			s1.Normal = WorldNormalVector( i , UnpackScaleNormal( tex2D( _FlakesNormal, uv_FlakesRGBcolorvariationAmask ), _FlakesBump ) );
			s1.Emission = float3( 0,0,0 );
			float lerpResult218 = lerp( _BaseMetallic , _FlakesMetallic , FlakeMask284);
			s1.Metallic = lerpResult218;
			float lerpResult232 = lerp( _BaseSmoothness , _FlakesSmoothness , FlakeMask284);
			s1.Smoothness = lerpResult232;
			float fresnelNdotV279 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode279 = ( 0.05 + 1.0 * pow( 1.0 - fresnelNdotV279, 5.0 ) );
			float lerpResult306 = lerp( i.vertexColor.r , 1.0 , _BaseOcclusion);
			s1.Occlusion = ( saturate( ( 1.0 - fresnelNode279 ) ) * lerpResult306 );

			data.light = gi.light;

			UnityGI gi1 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g1 = UnityGlossyEnvironmentSetup( s1.Smoothness, data.worldViewDir, s1.Normal, float3(0,0,0));
			gi1 = UnityGlobalIllumination( data, s1.Occlusion, s1.Normal, g1 );
			#endif

			float3 surfResult1 = LightingStandard ( s1, viewDir, gi1 ).rgb;
			surfResult1 += s1.Emission;

			SurfaceOutputStandardSpecular s166 = (SurfaceOutputStandardSpecular ) 0;
			s166.Albedo = float3( 0,0,0 );
			float2 uv_CoatNormal = i.uv_texcoord * _CoatNormal_ST.xy + _CoatNormal_ST.zw;
			s166.Normal = WorldNormalVector( i , UnpackScaleNormal( tex2D( _CoatNormal, uv_CoatNormal ), _CoatBump ) );
			s166.Emission = float3( 0,0,0 );
			float3 temp_cast_1 = (_Specintensity).xxx;
			s166.Specular = temp_cast_1;
			s166.Smoothness = _CoatSmoothness;
			s166.Occlusion = 1.0;

			data.light = gi.light;

			UnityGI gi166 = gi;
			#ifdef UNITY_PASS_FORWARDBASE
			Unity_GlossyEnvironmentData g166 = UnityGlossyEnvironmentSetup( s166.Smoothness, data.worldViewDir, s166.Normal, float3(0,0,0));
			gi166 = UnityGlobalIllumination( data, s166.Occlusion, s166.Normal, g166 );
			#endif

			float3 surfResult166 = LightingStandardSpecular ( s166, viewDir, gi166 ).rgb;
			surfResult166 += s166.Emission;

			float3 lerpResult208 = lerp( surfResult1 , surfResult166 , ( ( fresnelNode279 * _CoatAmount ) * lerpResult306 ));
			c.rgb = lerpResult208;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15600
0;576;1102;452;-740.5997;-1125.817;1.07254;True;False
Node;AmplifyShaderEditor.RangedFloatNode;330;-1940.113,-90.63483;Float;False;Property;_scale;scale;18;0;Create;True;0;0;False;0;0;0.992;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;331;-1774.515,-61.7677;Float;False;Property;_power;power;17;0;Create;True;0;0;False;0;0;0.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;329;-1943.947,-186.6538;Float;False;Property;_bias;bias;20;0;Create;True;0;0;False;0;0;0.119;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;201;-1509.492,-219.6261;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;216;-523.6835,317.6824;Float;False;Property;_FlakesColor1;Flakes Color 1;7;0;Create;True;0;0;False;0;1,0.9310344,0,0;0.2050761,0.2075472,0.1928622,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;263;-528.714,511.8733;Float;False;Property;_FlakesColor2;Flakes Color 2;8;0;Create;True;0;0;False;0;1,0.9310344,0,0;0.3004628,0.3005254,0.3018868,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;288;-913.3121,564.4912;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-547.7504,-90.41002;Float;False;0;228;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;277;-185.3526,627.3438;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;279;-578.8433,1312.186;Float;True;Standard;WorldNormal;ViewDir;False;5;0;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;296;-270.6724,1311.369;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;238;-606.7047,1688.711;Float;False;Property;_BaseOcclusion;Base Occlusion;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;290;439.7888,148.8591;Float;False;Property;_FlakeColorVariationAmount;Flake Color Variation Amount;6;0;Create;True;0;0;False;0;0;0.076;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;307;-265.9991,1662.315;Float;False;Constant;_Float0;Float 0;17;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-606.2405,1563.867;Float;False;Property;_CoatAmount;Coat Amount;15;0;Create;True;0;0;False;0;0;0.992;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;271;20.57252,-329.7649;Float;False;Property;_BaseColor2;Base Color 2;1;0;Create;True;0;0;False;0;1,0.9310344,0,0;1,0.007968127,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;4;23.15472,-507.9827;Float;False;Property;_BaseColor1;Base Color 1;0;0;Create;True;0;0;False;0;1,0.9310344,0,0;1,0,0.2160807,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;301;-271.002,1494.117;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;291;427.4925,136.2562;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;228;-91.33389,-112.8089;Float;True;Property;_FlakesRGBcolorvariationAmask;Flakes (RGB = color variation, A = mask);5;0;Create;True;0;0;False;0;2741be98b31d56c43ad9cfbcaf99a799;16d574e53541bba44a84052fa38778df;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;219;798.0975,265.6939;Float;False;Property;_BaseMetallic;Base Metallic;2;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;278;762.8654,-251.6517;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;287;880.5789,28.53017;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-561.7686,221.575;Float;False;Property;_FlakesBump;Flakes Bump;12;0;Create;True;0;0;False;0;0;0.074;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;991.5909,1160.397;Float;False;Property;_CoatBump;Coat Bump;14;0;Create;True;0;0;False;0;0;0.17;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;204;430.6655,633.4697;Float;False;Property;_FlakesSmoothness;Flakes Smoothness;10;0;Create;True;0;0;False;0;0;0.403;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;795.6452,351.8852;Float;False;Property;_FlakesMetallic;Flakes Metallic;9;0;Create;True;0;0;False;0;0;0.549;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;286;839.382,441.7393;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;306;-5.898457,1657.418;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;298;-32.6076,1316.134;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-257.3932,1397.812;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;284;291.885,-1.620189;Float;False;FlakeMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;233;431.4409,553.8036;Float;False;Property;_BaseSmoothness;Base Smoothness;3;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;285;458.2278,706.8754;Float;False;284;FlakeMask;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;227;745.086,-103.8213;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;281;941.591,1054.996;Float;False;1016.546;470.1129;This mirror layer that to mimc a coating layer;1;172;Coating Layer (Specular);1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;232;793.2447,607.6343;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;171;1346.064,1104.996;Float;True;Property;_CoatNormal;Coat Normal;13;0;Create;True;0;0;False;0;None;b3d940e75e1f5d24684cd93a2758e1bf;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;0.5;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;299;218.9914,1324.712;Float;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;7;-131.0492,180.0499;Float;True;Property;_FlakesNormal;Flakes Normal;11;0;Create;True;0;0;False;0;None;a268ab862991c4743a9281c69bb2c36a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;217;1219.931,-40.31573;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;211;1204.345,1326.56;Float;False;Property;_Specintensity;Spec intensity;19;0;Create;True;0;0;False;0;1;6.25;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;308;231.0996,1464.722;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;218;1208.977,277.6431;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;172;1340.61,1442.109;Float;False;Property;_CoatSmoothness;Coat Smoothness;16;0;Create;True;0;0;False;0;0;0.9094117;0.05;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;166;1703.137,1189.135;Float;False;Specular;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;319;1992.36,1548.037;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomStandardSurface;1;1730.49,170.9699;Float;False;Metallic;Tangent;6;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,1;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;324;2671.366,-7.801315;Float;False;Lerp White To;-1;;3;047d7c189c36a62438973bad9d37b1c2;0;2;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;208;2395.602,1132.678;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;328;2756.206,1064.791;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;ASESampleShaders/Double Layer Custom Surface;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;292;-1540.492,-275.3257;Float;False;348.1;312.8;Comment;0;Dual Toning Factor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;293;-611.7687,-557.9827;Float;False;2602.156;1370.458;Comment;0;Base Layer With Dual Toning Flakes;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;280;-628.1406,1261.356;Float;False;1024.147;552.1847;Simple fresnel blend;0;Blend Factor;1,1,1,1;0;0
WireConnection;201;1;329;0
WireConnection;201;2;330;0
WireConnection;201;3;331;0
WireConnection;288;0;201;0
WireConnection;277;0;216;0
WireConnection;277;1;263;0
WireConnection;277;2;288;0
WireConnection;296;0;279;0
WireConnection;291;0;277;0
WireConnection;228;1;9;0
WireConnection;278;0;4;0
WireConnection;278;1;271;0
WireConnection;278;2;201;0
WireConnection;306;0;301;1
WireConnection;306;1;307;0
WireConnection;306;2;238;0
WireConnection;298;0;296;0
WireConnection;237;0;279;0
WireConnection;237;1;47;0
WireConnection;284;0;228;4
WireConnection;227;0;291;0
WireConnection;227;1;228;0
WireConnection;227;2;290;0
WireConnection;232;0;233;0
WireConnection;232;1;204;0
WireConnection;232;2;285;0
WireConnection;171;5;180;0
WireConnection;299;0;298;0
WireConnection;299;1;306;0
WireConnection;7;1;9;0
WireConnection;7;5;11;0
WireConnection;217;0;278;0
WireConnection;217;1;227;0
WireConnection;217;2;287;0
WireConnection;308;0;237;0
WireConnection;308;1;306;0
WireConnection;218;0;219;0
WireConnection;218;1;5;0
WireConnection;218;2;286;0
WireConnection;166;1;171;0
WireConnection;166;3;211;0
WireConnection;166;4;172;0
WireConnection;319;0;308;0
WireConnection;1;0;217;0
WireConnection;1;1;7;0
WireConnection;1;3;218;0
WireConnection;1;4;232;0
WireConnection;1;5;299;0
WireConnection;208;0;1;0
WireConnection;208;1;166;0
WireConnection;208;2;319;0
WireConnection;328;13;208;0
ASEEND*/
//CHKSM=29E3CD8E36CCAF06C69FE98504C9967C9BB8292C