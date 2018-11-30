using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public abstract class DDOLsingleton<T> : MonoBehaviour where T : DDOLsingleton<T>
{
    protected static object obj = new object();

    protected static T _instance;
    public static T Instance
    {
        get {
            lock(obj)
            {
                if(_instance==null)
                {
                    GameObject go = GameObject.Find("DDOLsingleton");
                    if(go==null)
                    {
                        go = new GameObject("DDOLsingleton");
                        DontDestroyOnLoad(go);
                    }
                    _instance = go.GetComponent<T>();
                    if (_instance == null)
                    {
                        _instance = go.AddComponent<T>();
                    }
                }

                return _instance;
            }
        }
    }

}

public abstract class SampleSingleton<T> where T: class,new()
{
    protected static T _instance;
    public static T Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new T();
            }
            return _instance;
        }
   
    }
}


public class TestSingleton:DDOLsingleton<TestSingleton>
{
    public void TTT()
    {
        Debug.Log("dont destory on load singleton");
    }
}

public class TestSimpleSingleton:SampleSingleton<TestSimpleSingleton>
{
    public void TTTT()
    {
        Debug.Log(" unparent singleton ");
    }
}


public class SingletonFarent : MonoBehaviour
{
    private void Start()
    {
        TestSingleton.Instance.TTT();

        TestSimpleSingleton.Instance.TTTT();

        AnotherS.Instance.AAA(" test");
    }
}