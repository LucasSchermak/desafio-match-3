using UnityEngine;

namespace Gazeus.DesafioMatch3.ScriptableObjects
{
    [CreateAssetMenu(fileName = "ParticlePrefabRepository", menuName = "Gameplay/ParticlePrefabRepository")]
    public class ParticlePrefabRepository : ScriptableObject
    {
        [SerializeField] private GameObject[] _ParticleTypePrefabList;

        public GameObject[] ParticleTypePrefabList => _ParticleTypePrefabList;
    }
}
