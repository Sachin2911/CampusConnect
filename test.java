import android.Manifest;
import android.content.Context;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Bundle;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import androidx.core.app.ActivityCompat;
import androidx.fragment.app.FragmentActivity;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdate;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.OnMapReadyCallback;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class ContentHome extends FragmentActivity implements OnMapReadyCallback {

    private GoogleMap mMap;
    private FusedLocationProviderClient fusedLocationClient;
    private FirebaseAuth auth;
    private FirebaseFirestore firestore;
    private Set<Marker> markers = new HashSet<>();
    private boolean markersGenerated = false;
    private Position currentPosition;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_content_home);

        // Initialize Firebase components
        auth = FirebaseAuth.getInstance();
        firestore = FirebaseFirestore.getInstance();

        // Obtain the SupportMapFragment and get notified when the map is ready to be used.
        SupportMapFragment mapFragment = (SupportMapFragment) getSupportFragmentManager()
                .findFragmentById(R.id.map);
        mapFragment.getMapAsync(this);

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
    }

    @Override
    public void onMapReady(GoogleMap googleMap) {
        mMap = googleMap;

        // Enable the My Location button
        mMap.setMyLocationEnabled(true);

        // Call the function to initialize the map
        initializeMap();
    }

    private void initializeMap() {
        // Fetch the active coordinates
        getActiveCoordinates().addOnSuccessListener(coordinates -> {
            // Generate markers and display them on the map
            generateMarkers(coordinates);

            // Get the current location and generate circles
            getCurrentLocation();
        });
    }

    private void generateMarkers(List<LatLng> coordinates) {
        if (!coordinates.isEmpty()) {
            // Clear the existing markers before adding new ones
            for (Marker marker : markers) {
                marker.remove();
            }
            markers.clear();

            CollectionReference activeCollection = firestore.collection("active");
            activeCollection.get().addOnCompleteListener(task -> {
                if (task.isSuccessful()) {
                    QuerySnapshot snapshot = task.getResult();
                    if (snapshot != null) {
                        List<DocumentSnapshot> docs = snapshot.getDocuments();
                        for (int i = 0; i < coordinates.size(); i++) {
                            // Auto generated Marker Id's
                            MarkerOptions markerOptions = new MarkerOptions();
                            LatLng position = coordinates.get(i);
                            markerOptions.position(position);

                            // Find the document in the snapshot that matches the current coordinate
                            QueryDocumentSnapshot matchingDoc = null;
                            for (DocumentSnapshot docSnapshot : docs) {
                                Double latitude = docSnapshot.getDouble("latitude");
                                Double longitude = docSnapshot.getDouble("longitude");
                                if (latitude != null && longitude != null &&
                                        position.latitude == latitude &&
                                        position.longitude == longitude) {
                                    matchingDoc = docSnapshot;
                                    break;
                                }
                            }

                            if (matchingDoc != null) {
                                String uid = matchingDoc.getId();
                                // Fetch the user's name from Firestore using the UID
                                CollectionReference usersCollection = firestore.collection("users");
                                usersCollection.document(uid).get().addOnCompleteListener(userTask -> {
                                    if (userTask.isSuccessful()) {
                                        DocumentSnapshot userSnapshot = userTask.getResult();
                                        if (userSnapshot != null && userSnapshot.exists()) {
                                            String name = userSnapshot.getString("group");
                                            if (name == null) {
                                                name = "Unknown User";
                                            }

                                            markerOptions.title(name);
                                            markerOptions.snippet("Tap to view details");

                                            Marker marker = mMap.addMarker(markerOptions);
                                            marker.setTag(uid);
                                            markers.add(marker);
                                        }
                                    }
                                });
                            }
                        }

                        markersGenerated = true;
                    }
                }
            });
        }
    }

    private void getCurrentLocation() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
            fusedLocationClient.getLastLocation().addOnSuccessListener(location -> {
                if (location != null) {
                    currentPosition = new Position(location.getLatitude(), location.getLongitude());
                    CameraPosition cameraPosition = new CameraPosition.Builder()
                            .target(new LatLng(currentPosition.getLatitude(), currentPosition.getLongitude()))
                            .zoom(15)
                            .build();
                    CameraUpdate cameraUpdate = CameraUpdateFactory.newCameraPosition(cameraPosition);
                    mMap.animateCamera(cameraUpdate);

                    // Generate markers again after getting the current location
                    if (markersGenerated) {
                        generateMarkers(getActiveCoordinates());
                    }
                }
            });
        } else {
            // Request location permission if not granted
            ActivityCompat.requestPermissions(this,
                    new String[]{Manifest.permission.ACCESS_FINE_LOCATION},
                    1);
        }
    }

    private Task<List<LatLng>> getActiveCoordinates() {
        List<LatLng> coordinates = new ArrayList<>();
        CollectionReference activeCollection = firestore.collection("active");
        return activeCollection.get().continueWith(task -> {
            QuerySnapshot snapshot = task.getResult();
            if (snapshot != null) {
                List<DocumentSnapshot> docs = snapshot.getDocuments();
                for (DocumentSnapshot doc : docs) {
                    Double latitude = doc.getDouble("latitude");
                    Double longitude = doc.getDouble("longitude");
                    if (latitude != null && longitude != null) {
                        coordinates.add(new LatLng(latitude, longitude));
                    }
                }
            }
            return coordinates;
        });
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        if (requestCode == 1) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                getCurrentLocation();
            } else {
                // Permission denied, handle it accordingly (show a message or request again)
            }
        }
    }
}
